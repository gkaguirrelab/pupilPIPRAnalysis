outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/OSAFigures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% group response images
timebase = 0:0.02:13.98;

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
errBar(1,:) = groupAverageResponse{1}.Mel_SEM;
errBar(2,:) = errBar(1,:);
shadedErrorBar(timebase, groupAverageResponse{1}.Mel*100, errBar*100, 'lineProps', '-b')
xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;
ax1.YGrid = 'on';
ax1.XGrid = 'on';
pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['melGroup.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
errBar(1,:) = groupAverageResponse{1}.LMS_SEM;
errBar(2,:) = errBar(1,:);
shadedErrorBar(timebase, groupAverageResponse{1}.LMS*100, errBar*100, 'lineProps', '-k')
xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;
ax1.YGrid = 'on';
ax1.XGrid = 'on';
pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['LMSGroup.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
errBar(1,:) = groupAverageResponse{1}.Mel_SEM;
errBar(2,:) = errBar(1,:);
shadedErrorBar(timebase, groupAverageResponse{1}.Mel*100, errBar*100, 'lineProps', '-b')
errBar(1,:) = groupAverageResponse{1}.LMS_SEM;
errBar(2,:) = errBar(1,:);
shadedErrorBar(timebase, groupAverageResponse{1}.LMS*100, errBar*100, 'lineProps', '-k')
xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;
ax1.YGrid = 'on';
ax1.XGrid = 'on';
pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['LMSMelCombinedGroup.pdf']), 'pdf');
close(plotFig)

%% group response images without SEM
timebase = 0:0.02:13.98;

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
plot(timebase, groupAverageResponse{1}.Mel*100, 'Color', 'b', 'LineWidth', 3)
xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;

pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['melGroup_noSEM.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
plot(timebase, groupAverageResponse{1}.LMS*100, 'Color', [0.4 0.4 0.4], 'LineWidth', 3)
xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;

pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['LMSGroup_noSEM.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
plot(timebase, groupAverageResponse{1}.LMS*100, 'Color', [0.4 0.4 0.4], 'LineWidth', 3)
plot(timebase, groupAverageResponse{1}.Mel*100, 'Color', 'b', 'LineWidth', 3)
xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;

pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['LMSMelCombinedGroup_noSEM.pdf']), 'pdf');
close(plotFig)

%% repeatability of response shapes
timebase = 0:0.02:13.98;

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
plot(timebase, groupAverageResponse{1}.Mel*100, '-.', 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, groupAverageResponse{2}.Mel*100,  'Color', 'b', 'LineWidth', 1)

xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);
ax1 = gca;

pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['melGroup_repeatability.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
line([1 4], [5 5], 'LineWidth', 4, 'Color', 'k');
plot(timebase, groupAverageResponse{1}.LMS*100, '-.', 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
plot(timebase, groupAverageResponse{2}.LMS*100,  'Color', [0.3 0.3 0.3], 'LineWidth', 1)

xlabel('Time (s)');
ylabel('Pupil Diameter (% Change)')
ylim([-40 10]);

pbaspect([1 1 1])
saveas(plotFig,fullfile(outDir, ['LMSGroup_repeatability.pdf']), 'pdf');
close(plotFig)

%% looking at two subjects with varying mel/lms ratios
lowMeltoLMSSubject = 'MELA_0037';
whichSubject = cellfun(@(x) strcmp(x, lowMeltoLMSSubject), goodSubjects{2}.ID);
[maxValue, lowSubjectIndex] = max(whichSubject);


highMeltoLMSSubject = 'MELA_0026';
whichSubject = cellfun(@(x) strcmp(x, highMeltoLMSSubject), goodSubjects{2}.ID);
[maxValue, highSubjectIndex] = max(whichSubject);

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{2}.Mel(lowSubjectIndex,:), 'Color', 'b', 'LineWidth', 3)
plot(timebase, averageResponsePerSubject{2}.LMS(lowSubjectIndex,:), 'Color', [0.4 0.4 0.4], 'LineWidth', 3)
saveas(plotFig,fullfile(outDir, ['lowMeltoLMSSubject.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{2}.Mel(highSubjectIndex,:), 'Color', 'b', 'LineWidth', 3)
plot(timebase, averageResponsePerSubject{2}.LMS(highSubjectIndex,:), 'Color', [0.4 0.4 0.4], 'LineWidth', 3)
saveas(plotFig,fullfile(outDir, ['highMeltoLMSSubject.pdf']), 'pdf');
close(plotFig)

