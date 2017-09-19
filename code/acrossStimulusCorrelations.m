function acrossStimulusCorrelations(amplitudesPerSubject, dropboxAnalysisDir)

% set up where to save our plots
subDir = 'pupilPIPRAnalysis/IAMP/acrossStimulusCorrelations';
comparisonsX = {'LMS', 'Blue', 'SilentSubstitionAverage', 'BluetoRed'};
comparisonsY = {'Mel', 'Red', 'PIPRAverage', 'MeltoLMS'};

for session = 1:length(amplitudesPerSubject)
    outDir = fullfile(dropboxAnalysisDir, subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    for comparison = 1:length(comparisonsX)
        
        plotFig = figure;
        prettyScatterplots(amplitudesPerSubject{session}.(comparisonsX{comparison}).*100, amplitudesPerSubject{session}.(comparisonsY{comparison}).*100, amplitudesPerSubject{session}.([comparisonsX{comparison}, '_SEM']).*100, amplitudesPerSubject{session}.([comparisonsY{comparison}, '_SEM']).*100, 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', [comparisonsX{comparison}, ' Amplitude (%)'], 'yLabel', [comparisonsY{comparison}, ' Amplitude (%)'], 'lineOfBestFit', 'on', 'significance', 'spearman', 'save', fullfile(dropboxAnalysisDir, subDir, num2str(session), [comparisonsX{comparison}, 'x' comparisonsY{comparison}, '.png']), 'saveType', 'png')
        close(plotFig)
    end
end



close all

end % end function