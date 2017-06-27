function figures(goodSubjects, amplitudes, amplitudesSEM, averageBlueCombined, averageLMSCombined, averageMelCombined, averageRedCombined, semBlue, semLMS, semMel, semRed, dropboxAnalysisDir)

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Figure 1

%% Figure 2
% a. Sparkline of individual subjects
plotSparkline(goodSubjects, averageBlueCombined, averageLMSCombined, averageMelCombined, averageRedCombined, semBlue, semLMS, semMel, semRed, dropboxAnalysisDir)

% b. group average responses for each stimulus type for each session

% make average responses
for session = 1:2
    for timepoints = 1:length(averageLMSCombined{session})
        LMSAverage{session}(1,timepoints) = nanmean(averageLMSCombined{session}(:,timepoints));
        MelAverage{session}(1,timepoints) = nanmean(averageMelCombined{session}(:,timepoints));
        BlueAverage{session}(1,timepoints) = nanmean(averageBlueCombined{session}(:,timepoints));
        RedAverage{session}(1,timepoints) = nanmean(averageRedCombined{session}(:,timepoints));
    end
end

stimulusOrder = {'LMS' 'Melanopsin' 'Blue' 'Red'};
plotFig = figure;


for stimulus = 1:size(stimulusOrder,2)
    subplot(2,2,stimulus)
    if stimulus == 1 % LMS
        response = LMSAverage;
    elseif stimulus == 2 % mel
        response = MelAverage;
    elseif stimulus == 3 % blue
        response = BlueAverage;
    elseif stimulus == 4 % red
        response = RedAverage;
    end
    plot((1:size(response{1},2))*0.02, response{1}, 'Color', 'k')
    hold on
    plot((1:size(response{1},2))*0.02, response{2}, 'Color', 'b')
    if stimulus == 1
        legend('First Session', 'Second Session', 'Location', 'SouthEast')
    end
    xlabel('Time (s)')
    ylabel('Pupil Diameter (% Change)')
    ylim([-0.5 0.1])
    title([stimulusOrder{stimulus}])
end
saveas(plotFig, fullfile(outDir, ['2b.pdf']), 'pdf');
close(plotFig)

%% Figure 3: overall scaling of the amplitude response
% a: people vary in overall pupil responsivness

        
        
        
        