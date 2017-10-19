function analyzeModeledResponseIntegrationTime(totalResponseArea, amplitudesPerSubject, dropboxAnalysisDir)

stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
comparison1 = {1, 1, 2};
comparison2 = {2, 3, 3};

for comparison = 1:length(comparison1)
    for stimulus = 1:length(stimuli)
        
        minX = min(totalResponseArea{comparison1{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison1{comparison}}.(stimuli{stimulus}));
        maxX = max(totalResponseArea{comparison1{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison1{comparison}}.(stimuli{stimulus}));
        minY = min(totalResponseArea{comparison2{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison2{comparison}}.(stimuli{stimulus}));
        maxY = max(totalResponseArea{comparison2{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison2{comparison}}.(stimuli{stimulus}));
        maxValue = max([maxX, maxY]);
        minValue = min([minX, minY]);
        
        [ pairedResponseIntegrationTime ] = pairResultAcrossSessions(goodSubjects{comparison1{comparison}}.ID, goodSubjects{comparison2{comparison}}.ID, totalResponseArea{comparison1{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison1{comparison}}.(stimuli{stimulus}), totalResponseArea{comparison2{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison2{comparison}}.(stimuli{stimulus}), dropboxAnalysisDir, 'subdir', 'responseIntegrationTime/modeled', 'saveName', [stimuli{stimulus}, '_', num2str(comparison1{comparison}), 'x', num2str(comparison2{comparison})], 'xLims', [minValue maxValue], 'yLims', [minValue maxValue]);
        
    end
end

for session = 1:3
    plotFig = figure;
    hold on
    bplot(totalResponseArea{session}.LMS./amplitudesPerSubject{session}.LMS, 1, 'color', 'k')
    bplot(totalResponseArea{session}.Mel./amplitudesPerSubject{session}.Mel, 2, 'color', 'c')
    bplot(totalResponseArea{session}.Blue./amplitudesPerSubject{session}.Blue, 3, 'color', 'b')
    bplot(totalResponseArea{session}.Red./amplitudesPerSubject{session}.Red, 4, 'color', 'r')
    xticks([1, 2, 3, 4])
    xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
    saveas(plotFig, fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/responseIntegrationTime/modeled', ['compareStimuli_responseIntegrationTime_', num2str(session), '.png']), 'png');
    close(plotFig)
end

end % end function