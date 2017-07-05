function analyzePIPR(goodSubjects, amplitudes, averageBlueCombined, averageRedCombined, dropboxAnalysisDir)

% The purpose of this function is to determine which calculation of the
% PIPR gives us the largest value. This function averages computes the net
% PIPR at various time windows, and then plots the average PIPR across
% subjects against each time window

subDir = 'pupilPIPRAnalysis/IAMP/calculatePIPR';
outDir = fullfile(dropboxAnalysisDir,subDir);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% First, look at pipr computed at a single timepoint
index = 0;
for tt = 4:0.02:13.98 % loop over every time point from light offset to the end of the run
    index = index + 1;
    [pipr, netPipr]  = calculatePIPR(goodSubjects, amplitudes, dropboxAnalysisDir, 'computeMethod', 'window', 'timeOn', tt, 'timeOff', tt);
    [ netPIPRCombined ] = combineResultAcrossSessions(goodSubjects, netPipr{1}, netPipr{2});
    averagePIPR(index) = mean(netPIPRCombined);
end
plotFig1 = figure;
plot(4:0.02:13.98, averagePIPR, 'o')
xlabel('Timepoint when PIPR was Evaluated')
ylabel('Average Net PIPR')
saveas(plotFig1, fullfile(outDir, ['instantaneous.pdf']), 'pdf');
close(plotFig1)

% Second, look at pipr computed at a from a given timepoint until the end
% of the trial
index = 0;
for tt = 4:0.02:13.98 % loop over every time point from light offset to the end of the run
    index = index + 1;
    [pipr, netPipr]  = calculatePIPR(goodSubjects, amplitudes, dropboxAnalysisDir, 'computeMethod', 'window', 'timeOn', tt, 'timeOff', 14);
    [ netPIPRCombined ] = combineResultAcrossSessions(goodSubjects, netPipr{1}, netPipr{2});
    averagePIPR(index) = mean(netPIPRCombined);
end
plotFig2 = figure;
plot(4:0.02:13.98, averagePIPR, 'o')
xlabel('Timepoint for beginning of window when PIPR was Evaluated')
ylabel('Average Net PIPR')
saveas(plotFig2, fullfile(outDir, ['window.pdf']), 'pdf');
close(plotFig2)