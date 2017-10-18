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
errBar(1,:) = groupAverageResponse{1}.Mel_SEM;
errBar(2,:) = errBar(1,:);
shadedErrorBar(timebase, groupAverageResponse{1}.Mel*100, errBar*100, 'lineProps', '-b')
plot(timebase, groupAverageResponse{1}.Mel*100, 'Color', [0.5 0.5 1], 'LineWidth', 5)
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
errBar(1,:) = groupAverageResponse{1}.LMS_SEM;
errBar(2,:) = errBar(1,:);
shadedErrorBar(timebase, groupAverageResponse{1}.LMS*100, errBar*100, 'lineProps', '-k')
plot(timebase, groupAverageResponse{1}.LMS*100, 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
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
plot(timebase, groupAverageResponse{1}.LMS*100, 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
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
%plot(timebase, groupAverageResponse{1}.Mel*100, '-.', 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, groupAverageResponse{1}.Mel*100, 'Color', [0.5 0.5 1], 'LineWidth', 5)

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
%plot(timebase, groupAverageResponse{1}.LMS*100, '-.', 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
plot(timebase, groupAverageResponse{1}.LMS*100, 'Color', [0.7 0.7 0.7], 'LineWidth', 5)

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
[maxValue, lowSubjectIndex2] = max(whichSubject);
whichSubject = cellfun(@(x) strcmp(x, lowMeltoLMSSubject), goodSubjects{1}.ID);
[maxValue, lowSubjectIndex1] = max(whichSubject);

highMeltoLMSSubject = 'MELA_0089';
whichSubject = cellfun(@(x) strcmp(x, highMeltoLMSSubject), goodSubjects{2}.ID);
[maxValue, highSubjectIndex2] = max(whichSubject);
whichSubject = cellfun(@(x) strcmp(x, highMeltoLMSSubject), goodSubjects{1}.ID);
[maxValue, highSubjectIndex1] = max(whichSubject);

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{1}.Mel(lowSubjectIndex1,:), 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, averageResponsePerSubject{1}.LMS(lowSubjectIndex1,:), 'Color', [0.7 0.7 0.7], 'LineWidth', 5)


saveas(plotFig,fullfile(outDir, ['lowMeltoLMSSubject_first.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{1}.Mel(lowSubjectIndex1,:), 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, averageResponsePerSubject{1}.LMS(lowSubjectIndex1,:), 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
plot(timebase, averageResponsePerSubject{2}.LMS(lowSubjectIndex2,:), 'Color', [0.3 0.3 0.3], 'LineWidth', 1)
plot(timebase, averageResponsePerSubject{2}.Mel(lowSubjectIndex2,:), 'Color', 'b', 'LineWidth', 1)

saveas(plotFig,fullfile(outDir, ['lowMeltoLMSSubject_combined.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{1}.Mel(highSubjectIndex1,:), 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, averageResponsePerSubject{1}.LMS(highSubjectIndex1,:), 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
ylim([-0.5 0.1])

saveas(plotFig,fullfile(outDir, ['highMeltoLMSSubject_first.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{1}.Mel(highSubjectIndex1,:), 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, averageResponsePerSubject{1}.LMS(highSubjectIndex1,:), 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
plot(timebase, averageResponsePerSubject{2}.LMS(highSubjectIndex2,:), 'Color', [0.3 0.3 0.3], 'LineWidth', 1)
plot(timebase, averageResponsePerSubject{2}.Mel(highSubjectIndex2,:), 'Color', 'b', 'LineWidth', 1)
ylim([-0.5 0.1])
saveas(plotFig,fullfile(outDir, ['highMeltoLMSSubject_combined.pdf']), 'pdf');
close(plotFig)


%% amplitude figure
subjectID = 'MELA_0003';
session = 1;
for session = 1:2
whichSubject = cellfun(@(x) strcmp(x, subjectID), goodSubjects{session}.ID);
[maxValue, subjectIndex] = max(whichSubject);

plotFig = figure;
plot(timebase, averageResponsePerSubject{session}.Mel(subjectIndex,:).*100, 'Color', [0.5 0.5 1], 'LineWidth', 5)
xlabel('Time (s)')
ylabel('Pupil Diameter (% Change)')

saveas(plotFig,fullfile(outDir, [session, '_amplitudeDemoSubject.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
plot(timebase, groupAverageResponse{1}.Mel.*100, 'Color', 'r', 'LineWidth', 5)
xlabel('Time (s)')
ylabel('Pupil Diameter (% Change)')

saveas(plotFig,fullfile(outDir, [session, '_amplitudeDemoModel.pdf']), 'pdf');
close(plotFig)

plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{session}.Mel(subjectIndex,:).*100, 'Color', [0.5 0.5 1], 'LineWidth', 5)
plot(timebase, groupAverageResponse{session}.Mel./abs(min(groupAverageResponse{session}.Mel))*amplitudesPerSubject{session}.Mel(subjectIndex)*100, 'Color', 'r', 'LineWidth', 5)

xlabel('Time (s)')
ylabel('Pupil Diameter (% Change)')
ylim([-45 5])

saveas(plotFig,fullfile(outDir, [num2str(session), '_amplitudeDemoModel_fitted_mel.pdf']), 'pdf');
close(plotFig)
plotFig = figure;
hold on
plot(timebase, averageResponsePerSubject{session}.LMS(subjectIndex,:).*100, 'Color', [0.7 0.7 0.7], 'LineWidth', 5)
plot(timebase, groupAverageResponse{session}.LMS./abs(min(groupAverageResponse{1}.LMS))*amplitudesPerSubject{session}.LMS(subjectIndex)*100, 'Color', 'r', 'LineWidth', 5)

xlabel('Time (s)')
ylabel('Pupil Diameter (% Change)')
ylim([-45 5])

saveas(plotFig,fullfile(outDir, [num2str(session), '_amplitudeDemoModel_fitted_lms.pdf']), 'pdf');
close(plotFig)
end

