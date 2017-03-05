function [ theResult ] = acrossSessionCorrelation(subjects, amplitudes, amplitudesSEM, dropboxAnalysisDir)

% We've shown that a meaningful representation of the pupil response to
% melanopsin stimulation is the amplitude of the pupil constriction to
% melanopsin stimulation normalized by 'pupil responsiveness', for which we
% can use the amplitude of the pupil constriction to LMS stimulation

% This function defines for each subject for each session the melanopsin
% pupil response, and then plots the response from the first session
% against the second session


for ss = 1:size(subjects{2},1) % loop over subjects that have completed both sessions
    subject = subjects{2}(ss,:);
    
    secondSessionIndex = ss;
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    for x = 1:size(subjects{1},1)
        if strcmp(subjects{1}(x,:),subject);
            firstSessionIndex = x;
        end
    end
  
    melNormedOne(ss) = amplitudes{1}(firstSessionIndex,6);
    melNormedTwo(ss) = amplitudes{2}(secondSessionIndex,6);
    semMelOverLMSOne(ss) = amplitudesSEM{1}(firstSessionIndex,6);
    semMelOverLMSTwo(ss) = amplitudesSEM{2}(secondSessionIndex,6);
    
    
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
end

% now do some plotting
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/testRetest');
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
xlim([ 0 maxValue ]);
ylim([ 0 maxValue ]);
saveas(plotFig, fullfile(outDir, ['melNormedTestRetest.png']), 'png');
close(plotFig);

% next pipr response
plotFig = figure;
hold on
errorbar(piprOne, piprTwo, semPIPRTwo, 'bo')
herrorbar(piprOne, piprTwo, semPIPROne, 'bo')
xlabel('PIPR (%) Session 1')
ylabel('PIPR (%) Session 2')
maxValue = max(max(piprOne,piprTwo));
minValue = min(min(piprOne,piprTwo));
xlim([ minValue maxValue ]);
ylim([ minValue maxValue ]);
axis square
saveas(plotFig, fullfile(outDir, ['PIPRTestRetest.png']), 'png');
close(plotFig);

% next mel+lms response
plotFig = figure;
hold on
errorbar(melPlusLMSOne, melPlusLMSTwo, semMelPlusLMSTwo, 'bo')
herrorbar(melPlusLMSOne, melPlusLMSTwo, semMelPlusLMSOne, 'bo')
xlabel('(Mel+LMS)/2 (%) Session 1')
ylabel('(Mel+LMS)/2 (%) Session 2')
maxValue = max(max(melPlusLMSOne,melPlusLMSTwo));
minValue = min(min(melPlusLMSOne,melPlusLMSTwo));
xlim([ minValue maxValue ]);
ylim([ minValue maxValue ]);
axis square
saveas(plotFig, fullfile(outDir, ['melPlusLMSTestRetest.png']), 'png');
close(plotFig);

% next blue+red response
plotFig = figure;
hold on
errorbar(bluePlusRedOne, bluePlusRedTwo, semBluePlusRedTwo, 'bo')
herrorbar(bluePlusRedOne, bluePlusRedTwo, semBluePlusRedOne, 'bo')
xlabel('(Blue+Red)/2 (%) Session 1')
ylabel('(Blue+Red)/2 (%) Session 2')
maxValue = max(max(bluePlusRedOne,bluePlusRedTwo));
minValue = min(min(bluePlusRedOne,bluePlusRedTwo));
xlim([ minValue maxValue ]);
ylim([ minValue maxValue ]);
axis square
saveas(plotFig, fullfile(outDir, ['bluePlusRedTestRetest.png']), 'png');
close(plotFig);


end % end function