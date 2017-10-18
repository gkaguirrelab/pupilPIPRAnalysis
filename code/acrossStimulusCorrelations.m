function acrossStimulusCorrelations(amplitudesPerSubject, totalResponseArea, dropboxAnalysisDir)


%% first the IAMP comparisons
% set up where to save our plots
subDir = 'pupilPIPRAnalysis/IAMP/acrossStimulusCorrelations';
comparisonsX = {'LMS', 'Blue', 'SilentSubstitutionAverage', 'BluetoRed'};
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

%% now the TPUP comparisons
% set up where to save our plots
subDir = 'pupilPIPRAnalysis/TPUP/acrossStimulusCorrelations';
comparisonsX = {'LMS', 'Blue'};
comparisonsY = {'Mel', 'Red'};
mins = [-220 -330];
maxs = [0 0];

for session = 1:length(amplitudesPerSubject)
    outDir = fullfile(dropboxAnalysisDir, subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    for comparison = 1:length(comparisonsX)
        
        plotFig = figure;
        prettyScatterplots(totalResponseArea{session}.(comparisonsX{comparison}), totalResponseArea{session}.(comparisonsY{comparison}), totalResponseArea{session}.([comparisonsX{comparison}]).*0, totalResponseArea{session}.([comparisonsY{comparison}]).*0, 'xLim', [mins(comparison) maxs(comparison)], 'yLim', [mins(comparison) maxs(comparison)], 'unity', 'on', 'plotOption', 'square', 'xLabel', [comparisonsX{comparison}, ' Amplitude (%)'], 'yLabel', [comparisonsY{comparison}, ' Amplitude (%)'], 'lineOfBestFit', 'on', 'significance', 'spearman', 'save', fullfile(dropboxAnalysisDir, subDir, num2str(session), ['totalResponseArea_', comparisonsX{comparison}, 'x' comparisonsY{comparison}, '.png']), 'saveType', 'png')
        close(plotFig)
    end
end




close all

end % end function