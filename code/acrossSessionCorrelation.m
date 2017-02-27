function [ theResult ] = acrossSessionCorrelation(subjects, amplitudes, dropboxAnalysisDir)

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
    melOne(ss) = amplitudes{1}(firstSessionIndex,2);
    melTwo(ss) = amplitudes{2}(secondSessionIndex,2);
    melNormedOne(ss) = amplitudes{1}(firstSessionIndex,2)/amplitudes{1}(firstSessionIndex,1);
    melNormedTwo(ss) = amplitudes{2}(secondSessionIndex,2)/amplitudes{2}(secondSessionIndex,1);
    piprOne(ss) = (amplitudes{1}(firstSessionIndex,3)*100)-(amplitudes{1}(firstSessionIndex,4)*100);
    piprTwo(ss) = (amplitudes{2}(secondSessionIndex,3)*100)-(amplitudes{2}(secondSessionIndex,4)*100);
    
    
end

% now do some plotting
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/testRetest');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% first mel response
plotFig = figure;
plot(melOne, melTwo, 'o')
xlabel('Mel Amplitude (%) Session 1')
ylabel('Mel Amplitude (%) Session 2')
axis square
maxValue = max(max(melOne,melTwo));
xlim([ 0 maxValue ]);
ylim([ 0 maxValue ]);
saveas(plotFig, fullfile(outDir, ['melTestRetest.png']), 'png');
close(plotFig);

% first mel response that's been normed by overall responsiveness
plotFig = figure;
plot(melNormedOne, melNormedTwo, 'o')
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
plot(piprOne, piprTwo, 'o')
xlabel('PIPR (%) Session 1')
ylabel('PIPR (%) Session 2')
maxValue = max(max(piprOne,piprTwo));
minValue = min(min(piprOne,piprTwo));
xlim([ minValue maxValue ]);
ylim([ minValue maxValue ]);
axis square
saveas(plotFig, fullfile(outDir, ['PIPRTestRetest.png']), 'png');
close(plotFig);


end % end function