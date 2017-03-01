function [ theResult ] = acrossSessionCorrelation(subjects, amplitudes, amplitudesSTD, numberOfTrials, dropboxAnalysisDir)

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
  
    melNormedOne(ss) = amplitudes{1}(firstSessionIndex,2)/amplitudes{1}(firstSessionIndex,1);
    melNormedTwo(ss) = amplitudes{2}(secondSessionIndex,2)/amplitudes{2}(secondSessionIndex,1);
    covarianceMelLMSOne = cov(amplitudes{1}(:,1), amplitudes{1}(:,2));
    covarianceMelLMSOne = covarianceMelLMSOne(1,2);
    semMelOverLMSOne(ss) = sqrt(1./((amplitudes{1}(firstSessionIndex,1).^2)).*(amplitudesSTD{1}(firstSessionIndex,2).^2)+(amplitudes{1}(firstSessionIndex,2).^2)./(amplitudes{1}(firstSessionIndex,1).^4).*(amplitudesSTD{1}(firstSessionIndex,1).^2)-2*amplitudes{1}(firstSessionIndex,2)./(amplitudes{1}(firstSessionIndex,1).^3)*covarianceMelLMSOne)./sqrt((numberOfTrials{1}(firstSessionIndex,1)+numberOfTrials{1}(firstSessionIndex,2))/2);
    covarianceMelLMSTwo = cov(amplitudes{2}(:,1), amplitudes{2}(:,2));
    covarianceMelLMSTwo = covarianceMelLMSTwo(1,2);
    semMelOverLMSTwo(ss) = sqrt(1./((amplitudes{2}(secondSessionIndex,1).^2)).*(amplitudesSTD{2}(secondSessionIndex,2).^2)+(amplitudes{2}(secondSessionIndex,2).^2)./(amplitudes{2}(secondSessionIndex,1).^4).*(amplitudesSTD{2}(secondSessionIndex,1).^2)-2*amplitudes{2}(secondSessionIndex,2)./(amplitudes{2}(secondSessionIndex,1).^3)*covarianceMelLMSTwo)./sqrt((numberOfTrials{2}(secondSessionIndex,1)+numberOfTrials{2}(secondSessionIndex,2))/2);
    
    
    piprOne(ss) = (amplitudes{1}(firstSessionIndex,3)*100)-(amplitudes{1}(firstSessionIndex,4)*100);
    piprTwo(ss) = (amplitudes{2}(secondSessionIndex,3)*100)-(amplitudes{2}(secondSessionIndex,4)*100);
    semPIPROne(ss) = 100*sqrt(amplitudesSTD{1}(firstSessionIndex,3).^2+amplitudesSTD{1}(firstSessionIndex,4).^2)./sqrt((numberOfTrials{1}(firstSessionIndex,3)+numberOfTrials{1}(firstSessionIndex,4))/2);
    semPIPRTwo(ss) = 100*sqrt(amplitudesSTD{2}(secondSessionIndex,3).^2+amplitudesSTD{2}(secondSessionIndex,4).^2)./sqrt((numberOfTrials{2}(secondSessionIndex,3)+numberOfTrials{2}(secondSessionIndex,4))/2);

    melPlusLMSOne(ss) = ((amplitudes{1}(firstSessionIndex,1)*100)+(amplitudes{1}(firstSessionIndex,2)*100/2));
    melPlusLMSTwo(ss) = (amplitudes{2}(secondSessionIndex,1)*100)+(amplitudes{2}(secondSessionIndex,2)*100/2);
    semMelPlusLMSOne(ss) = 100*sqrt(amplitudesSTD{1}(firstSessionIndex,1).^2+amplitudesSTD{1}(firstSessionIndex,2).^2)./sqrt((numberOfTrials{1}(firstSessionIndex,1)+numberOfTrials{1}(firstSessionIndex,2))/2);
    semMelPlusLMSTwo(ss) = 100*sqrt(amplitudesSTD{2}(secondSessionIndex,1).^2+amplitudesSTD{2}(secondSessionIndex,2).^2)./sqrt((numberOfTrials{2}(secondSessionIndex,1)+numberOfTrials{2}(secondSessionIndex,2))/2);

    bluePlusRedOne(ss) = ((amplitudes{1}(firstSessionIndex,3)*100)+(amplitudes{1}(firstSessionIndex,4)*100/2));
    bluePlusRedTwo(ss) = (amplitudes{2}(secondSessionIndex,3)*100)+(amplitudes{2}(secondSessionIndex,4)*100/2);
    semBluePlusRedOne(ss) = 100*sqrt(amplitudesSTD{1}(firstSessionIndex,3).^2+amplitudesSTD{1}(firstSessionIndex,4).^2)./sqrt((numberOfTrials{1}(firstSessionIndex,3)+numberOfTrials{1}(firstSessionIndex,4))/2);
    semBluePlusRedTwo(ss) = 100*sqrt(amplitudesSTD{2}(secondSessionIndex,3).^2+amplitudesSTD{2}(secondSessionIndex,4).^2)./sqrt((numberOfTrials{2}(secondSessionIndex,3)+numberOfTrials{2}(secondSessionIndex,4))/2);

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