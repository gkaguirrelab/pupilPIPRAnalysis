function [ rhoMel, melNormedOne, melNormedTwo ] = acrossSessionCorrelation(subjects, amplitudes, amplitudesSEM, TPUPAmplitudes, dropboxAnalysisDir)

% We've shown that a meaningful representation of the pupil response to
% melanopsin stimulation is the amplitude of the pupil constriction to
% melanopsin stimulation normalized by 'pupil responsiveness', for which we
% can use the amplitude of the pupil constriction to LMS stimulation

% This function defines for each subject for each session the melanopsin
% pupil response, and then plots the response from the first session
% against the second session


for ss = 1:size(subjects{2}{1},1) % loop over subjects that have completed both sessions
    subject = subjects{2}{1}(ss,:);
    
    secondSessionIndex = ss;
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    for x = 1:size(subjects{1}{1},1)
        if strcmp(subjects{1}{1}(x,:),subject);
            firstSessionIndex = x;
        end
    end
  
    melNormedOne(ss) = amplitudes{1}(firstSessionIndex,6);
    melNormedTwo(ss) = amplitudes{2}(secondSessionIndex,6);
    semMelOverLMSOne(ss) = amplitudesSEM{1}(firstSessionIndex,6);
    semMelOverLMSTwo(ss) = amplitudesSEM{2}(secondSessionIndex,6);
    
    melPercentPersistentOne(ss) = TPUPAmplitudes{1}{2}(firstSessionIndex,3)/(TPUPAmplitudes{1}{2}(firstSessionIndex,2) + TPUPAmplitudes{1}{2}(firstSessionIndex,3)) * 100;
    melPercentPersistentTwo(ss) = TPUPAmplitudes{2}{2}(secondSessionIndex,3)/(TPUPAmplitudes{2}{2}(secondSessionIndex,2) + TPUPAmplitudes{2}{2}(secondSessionIndex,3)) * 100;
    semMelPercentPersistentOne(ss) = 0;
    semMelPercentPersistentTwo(ss) = 0;
    
    LMSPercentPersistentOne(ss) = TPUPAmplitudes{1}{1}(firstSessionIndex,3)/(TPUPAmplitudes{1}{1}(firstSessionIndex,2) + TPUPAmplitudes{1}{1}(firstSessionIndex,3)) * 100;
    LMSPercentPersistentTwo(ss) = TPUPAmplitudes{2}{1}(secondSessionIndex,3)/(TPUPAmplitudes{2}{1}(secondSessionIndex,2) + TPUPAmplitudes{2}{1}(secondSessionIndex,3)) * 100;
    semLMSPercentPersistentOne(ss) = 0;
    semLMSPercentPersistentTwo(ss) = 0;
    
    redPercentPersistentOne(ss) = TPUPAmplitudes{1}{4}(firstSessionIndex,3)/(TPUPAmplitudes{1}{4}(firstSessionIndex,2) + TPUPAmplitudes{1}{4}(firstSessionIndex,3)) * 100;
    redPercentPersistentTwo(ss) = TPUPAmplitudes{2}{4}(secondSessionIndex,3)/(TPUPAmplitudes{2}{4}(secondSessionIndex,2) + TPUPAmplitudes{2}{4}(secondSessionIndex,3)) * 100;
    semRedPercentPersistentOne(ss) = 0;
    semRedPercentPersistentTwo(ss) = 0;
    
    bluePercentPersistentOne(ss) = TPUPAmplitudes{1}{3}(firstSessionIndex,3)/(TPUPAmplitudes{1}{3}(firstSessionIndex,2) + TPUPAmplitudes{1}{3}(firstSessionIndex,3)) * 100;
    bluePercentPersistentTwo(ss) = TPUPAmplitudes{2}{3}(secondSessionIndex,3)/(TPUPAmplitudes{2}{3}(secondSessionIndex,2) + TPUPAmplitudes{2}{3}(secondSessionIndex,3)) * 100;
    semBluePercentPersistentOne(ss) = 0;
    semBluePercentPersistentTwo(ss) = 0;
    
    piprOne(ss) = amplitudes{1}(firstSessionIndex,5)*100;
    piprTwo(ss) = amplitudes{2}(secondSessionIndex,5)*100;
    semPIPROne(ss) = amplitudesSEM{1}(firstSessionIndex,5)*100;
    semPIPRTwo(ss) = amplitudesSEM{2}(secondSessionIndex,5)*100;
    
    melPlusLMSOne(ss) = amplitudes{1}(firstSessionIndex,8)*100;
    melPlusLMSTwo(ss) = amplitudes{2}(secondSessionIndex,8)*100;
    semMelPlusLMSOne(ss) = amplitudesSEM{1}(firstSessionIndex,8)*100;
    semMelPlusLMSTwo(ss) = amplitudesSEM{2}(secondSessionIndex,8)*100;
    
    bluePlusRedOne(ss) = amplitudes{1}(firstSessionIndex,9)*100;
    bluePlusRedTwo(ss) = amplitudes{2}(secondSessionIndex,9)*100;
    semBluePlusRedOne(ss) = amplitudesSEM{1}(firstSessionIndex,9)*100;
    semBluePlusRedTwo(ss) = amplitudesSEM{2}(secondSessionIndex,9)*100;
    
    blueToRedOne(ss) = amplitudes{1}(firstSessionIndex,7);
    blueToRedTwo(ss) = amplitudes{2}(secondSessionIndex,7);
    semBlueToRedOne(ss) = amplitudesSEM{1}(firstSessionIndex,7);
    semBlueToRedTwo(ss) = amplitudesSEM{2}(secondSessionIndex,7);
    
    
end

% now do some plotting
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRanalysis/IAMP/testRetest');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% first mel response that's been normed by overall responsiveness
plotFig = figure;
hold on
errorbar(melNormedOne, melNormedTwo, semMelOverLMSTwo, 'bo')
herrorbar(melNormedOne, melNormedTwo, semMelOverLMSOne, 'bo')
plot(0:10,0:10,'-')
xlabel('Mel/LMS Session 1')
ylabel('Mel/LMS Session 2')
axis square
maxValue = max(max(melNormedOne,melNormedTwo));
minValue = min(min(melNormedOne,melNormedTwo));
xlim([ 0 maxValue ]);
ylim([ 0 maxValue ]);
% determine spearman correlation:
rho = corr(melNormedOne', melNormedTwo', 'type', 'Spearman');
rhoMel = rho;
legend(['rho = ', sprintf('%.2f', rho)])

saveas(plotFig, fullfile(outDir, ['melNormedTestRetest.png']), 'png');
close(plotFig);



% compute the test-retest reliability mentioned in the Zhou paper
for ss = 1:length(melNormedOne)
    squaredDifference(ss) = (melNormedOne(ss)-melNormedTwo(ss))^2;
    difference(ss) = melNormedOne(ss)-melNormedTwo(ss);
end

% previous method of calculating within subject SD trying to replicate the
% range dicussed by Zhou
withinSubjectSD = sqrt(sum(squaredDifference)/(2*length(melNormedOne)));
testRetestRepeatability = withinSubjectSD*2.77

% the limits of agreement for a typical bland-altman plot, however, are
% more simple

differenceSD = std(difference)
% the interval in within which we'd expect 95% of the differences between
% measurements to lie
plotFig = figure;
plot((melNormedOne+melNormedTwo)/2, melNormedOne-melNormedTwo, 'o')
hold on
line([min((melNormedOne+melNormedTwo)/2) max((melNormedOne+melNormedTwo)/2)], [(mean(melNormedOne-melNormedTwo) + 1.96*differenceSD) (mean(melNormedOne-melNormedTwo) + 1.96*differenceSD)]);
line([min((melNormedOne+melNormedTwo)/2) max((melNormedOne+melNormedTwo)/2)], [(mean(melNormedOne-melNormedTwo) - 1.96*differenceSD) (mean(melNormedOne-melNormedTwo) - 1.96*differenceSD)]);
line([min((melNormedOne+melNormedTwo)/2) max((melNormedOne+melNormedTwo)/2)], [(mean(melNormedOne-melNormedTwo)) mean(melNormedOne-melNormedTwo)], 'LineStyle', '--');

% these lines would be the so-called limits of agreement -- there's a 95%
% chance the difference between a second measurement and a first measurement 
% will within this range

title('Bland-Altman Plot')
xlabel('Average of the Two Measures')
ylabel('Difference of the Two Measures')
saveas(plotFig, fullfile(outDir, ['melNormed_Bland-AltmanPlot.png']), 'png');
saveas(plotFig, fullfile(outDir, ['melNormed_Bland-AltmanPlot.pdf']), 'pdf');

close(plotFig);


prettyScatterplots(melNormedOne, melNormedTwo, semMelOverLMSOne, semMelOverLMSTwo, 'xLim', [ minValue maxValue ], 'yLim', [ minValue maxValue ], 'xLabel', 'Mel/LMS Session 1', 'yLabel', 'Mel/LMS Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['melNormedTestRetest_pretty.png']), 'saveType', 'png', 'plotOption', 'square')

plotFig = figure;
prettyScatterplots(melNormedOne, melNormedTwo, semMelOverLMSOne, semMelOverLMSTwo, 'xLim', [ -0.2 1.8 ], 'yLim', [ -0.2 1.8 ], 'xLabel', 'Mel/LMS Session 1', 'yLabel', 'Mel/LMS Session 2', 'unity', 'on', 'significance', 'rho', 'plotOption', 'square')

saveas(plotFig, fullfile(outDir, ['melNormedTestRetest_pretty.pdf']), 'pdf');
close(plotFig);


% plot blue response normed by response to red (that is blue/red amplitude
% ratio)
plotFig = figure;
hold on
errorbar(blueToRedOne, blueToRedTwo, semBlueToRedTwo, 'bo')
herrorbar(blueToRedOne, blueToRedTwo, semBlueToRedOne, 'bo')
plot(0:10,0:10,'-')
xlabel('Blue/Red Session 1')
ylabel('Blue/Red Session 2')
axis square
maxValue = max(max(blueToRedOne,blueToRedTwo));
xlim([ 0 maxValue ]);
ylim([ 0 maxValue ]);
% determine spearman correlation:
rho = corr(blueToRedOne', blueToRedTwo', 'type', 'Spearman');
legend(['rho = ', num2str(rho)])
saveas(plotFig, fullfile(outDir, ['blueToRedTestRetest.png']), 'png');
close(plotFig);


% next pipr response
plotFig = figure;
hold on
errorbar(piprOne, piprTwo, semPIPRTwo, 'bo')
herrorbar(piprOne, piprTwo, semPIPROne, 'bo')
plot(-100:100,-100:100,'-')
xlabel('PIPR (%) Session 1')
ylabel('PIPR (%) Session 2')
maxValue = max(max(piprOne,piprTwo));
minValue = min(min(piprOne,piprTwo));
xlim([ minValue maxValue ]);
ylim([ minValue maxValue ]);
axis square
% determine spearman correlation:
rho = corr(piprOne', piprTwo', 'type', 'Spearman');
legend(['rho = ', num2str(rho)])
saveas(plotFig, fullfile(outDir, ['PIPRTestRetest.png']), 'png');
close(plotFig);
prettyScatterplots(piprOne, piprTwo, semPIPROne, semPIPRTwo, 'xLim', [ minValue maxValue ], 'yLim', [ minValue maxValue ], 'xLabel', 'PIPR Session 1', 'yLabel', 'PIPR Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['PIPRTestRetest_pretty.png']), 'saveType', 'png')


% next mel+lms response
plotFig = figure;
hold on
errorbar(melPlusLMSOne, melPlusLMSTwo, semMelPlusLMSTwo, 'bo')
herrorbar(melPlusLMSOne, melPlusLMSTwo, semMelPlusLMSOne, 'bo')
plot(-100:100,-100:100,'-')
xlabel('(Mel+LMS)/2 (%) Session 1')
ylabel('(Mel+LMS)/2 (%) Session 2')
maxValue = max(max(melPlusLMSOne,melPlusLMSTwo));
minValue = min(min(melPlusLMSOne,melPlusLMSTwo));
xlim([ minValue maxValue ]);
ylim([ minValue maxValue ]);
% determine spearman correlation:
rho = corr(melPlusLMSOne', melPlusLMSTwo', 'type', 'Spearman');
legend(['rho = ', num2str(rho)])
axis square
saveas(plotFig, fullfile(outDir, ['melPlusLMSTestRetest.png']), 'png');
close(plotFig);
prettyScatterplots(melPlusLMSOne, melPlusLMSTwo, semMelPlusLMSOne, semMelPlusLMSTwo, 'xLim', [ 0 60 ], 'yLim', [ 0 60 ], 'xLabel', '(Mel+LMS)/2 Session 1', 'yLabel', '(Mel+LMS)/2 Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['MelPlusLMSTestRetest_pretty.png']), 'saveType', 'png')
prettyScatterplots(melPlusLMSOne, melPlusLMSTwo, semMelPlusLMSOne, semMelPlusLMSTwo, 'xLim', [ 0 60 ], 'yLim', [ 0 60 ], 'xLabel', '(Mel+LMS)/2 Session 1', 'yLabel', '(Mel+LMS)/2 Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['MelPlusLMSTestRetest_pretty.pdf']), 'saveType', 'pdf')


% next blue+red response
plotFig = figure;
hold on
errorbar(bluePlusRedOne, bluePlusRedTwo, semBluePlusRedTwo, 'bo')
herrorbar(bluePlusRedOne, bluePlusRedTwo, semBluePlusRedOne, 'bo')
plot(-100:100,-100:100,'-')
xlabel('(Blue+Red)/2 (%) Session 1')
ylabel('(Blue+Red)/2 (%) Session 2')
maxValue = max(max(bluePlusRedOne,bluePlusRedTwo));
minValue = min(min(bluePlusRedOne,bluePlusRedTwo));
xlim([ 0 60 ]);
ylim([ 0 60 ]);
axis square
% determine spearman correlation:
rho = corr(bluePlusRedOne', bluePlusRedTwo', 'type', 'Spearman');
legend(['rho = ', num2str(rho)])
saveas(plotFig, fullfile(outDir, ['bluePlusRedTestRetest.png']), 'png');
close(plotFig);

prettyScatterplots(bluePlusRedOne, bluePlusRedTwo, semBluePlusRedOne, semBluePlusRedTwo, 'xLim', [ 0 60 ], 'yLim', [ 0 60 ], 'xLabel', '(Blue+Red)/2 Session 1', 'yLabel', '(Blue+Red)/2 Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['BluePlusRedTestRetest_pretty.png']), 'saveType', 'png')

% next % persistent response
plotFig = figure;
hold on
errorbar(melPercentPersistentOne, melPercentPersistentTwo, melPercentPersistentTwo*0, 'bo')
herrorbar(melPercentPersistentOne, melPercentPersistentTwo, melPercentPersistentTwo*0, 'bo')
plot(-100:100,-100:100,'-')
xlabel('(Blue+Red)/2 (%) Session 1')
ylabel('(Blue+Red)/2 (%) Session 2')
maxValue = max(max(melPercentPersistentOne,melPercentPersistentTwo));
minValue = min(min(melPercentPersistentOne,melPercentPersistentTwo));
xlim([ 0 60 ]);
ylim([ 0 60 ]);
axis square
% determine spearman correlation:
rho = corr(melPercentPersistentOne', melPercentPersistentTwo', 'type', 'Spearman');
legend(['rho = ', num2str(rho)])

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRanalysis/TPUP/testRetest');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['percentPersistent.png']), 'png');
close(plotFig);
prettyScatterplots(melPercentPersistentOne, melPercentPersistentTwo, melPercentPersistentOne*0, melPercentPersistentOne*0, 'xLim', [ 0 100 ], 'yLim', [ 0 100 ],'xLabel', '% Persistent Session 1', 'yLabel', '% Persistent Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['melPercentPersistent.png']), 'saveType', 'png')
prettyScatterplots(melPercentPersistentOne, melPercentPersistentTwo, melPercentPersistentOne*0, melPercentPersistentOne*0, 'xLim', [ 0 100 ], 'yLim', [ 0 100 ],'xLabel', '% Persistent Session 1', 'yLabel', '% Persistent Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['melPercentPersistent.pdf']), 'saveType', 'pdf')

prettyScatterplots(LMSPercentPersistentOne, LMSPercentPersistentTwo, LMSPercentPersistentOne*0, LMSPercentPersistentOne*0, 'xLim', [ 0 100 ], 'yLim', [ 0 100 ],'xLabel', '% Persistent Session 1', 'yLabel', '% Persistent Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['LMSPercentPersistent.pdf']), 'saveType', 'pdf')

prettyScatterplots(bluePercentPersistentOne, bluePercentPersistentTwo, LMSPercentPersistentOne*0, LMSPercentPersistentOne*0, 'xLim', [ 0 100 ], 'yLim', [ 0 100 ],'xLabel', '% Persistent Session 1', 'yLabel', '% Persistent Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['bluePercentPersistent.pdf']), 'saveType', 'pdf')

prettyScatterplots(redPercentPersistentOne, redPercentPersistentTwo, LMSPercentPersistentOne*0, LMSPercentPersistentOne*0, 'xLim', [ 0 100 ], 'yLim', [ 0 100 ],'xLabel', '% Persistent Session 1', 'yLabel', '% Persistent Session 2', 'unity', 'on', 'close', 'on', 'significance', 'rho', 'save', fullfile(outDir, ['redPercentPersistent.pdf']), 'saveType', 'pdf')



end % end function