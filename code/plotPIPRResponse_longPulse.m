function [piprCombined, averageMelCombined, averageLMSCombined, averageBlueCombined, averageRedCombined] = plotPIPRResponse_longPulse(goodSubjects, dropboxAnalysisDir)

% Function to plot the average PIPR response
% First, we determine which subjects can be kept for the analysis because
% they do not mean exclusion criteria
% Second, we plot the average pupil response to blue stimulation, red
% stimulation, and the subtracted PIPR response
% Finally plots a group average

% 12/12/2016, written by hmm




%% Create plots across subjects that show the average response to the red
%% stimulus, the blue stimulus, and the blue-red response


% Pre-allocate space for results variables
for session = 1:2;
    averageBlue{session} = [];
    semBlue{session} = [];
    averageBlueCombined{session} = [];
    averageRed{session} = [];
    semRed{session} = [];
    averageRedCombined{session} = [];
    pipr{session} = [];
    semPipr{session} = [];
    piprCombined{session} = [];
    averageBlueCombined{session} = [];
    averageRedCombined{session} = [];
    averageLMS{session} =[];
    semLMS{session} = [];
    averageLMSCombined{session} = [];
    
    averageMel{session} = [];
    averageMelCombined{session} = [];
    semMel{session} = [];
end

for session = 1:2;
    
    for ss = 1:size(goodSubjects{session}{1},1);
        ss
        session
        subject = goodSubjects{session}{1}(ss,:);
        numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulsePIPR', subject));
        numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
        
        % determine the date of a session
        dateList = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulsePIPR', subject));
        dateList = dateList(~ismember({dateList.name},{'.','..', '.DS_Store'}));
        
        date = goodSubjects{session}{2}(ss,:);
        
        blue = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
        red = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
        % create average pupil response for a given subject to the red or blue
        % stimulus
        for stimuli = 1:2;
            if stimuli == 1;
                color = blue;
            elseif stimuli == 2;
                color = red;
            end
            for timepoints = 1:length(color);
                if stimuli == 1;
                    averageBlue{session}(1, timepoints) = nanmean(color(timepoints, :));
                    semBlue{session}(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
                    averageBlueCombined{session}(ss, timepoints) = nanmean(color(timepoints, :));
                elseif stimuli == 2;
                    averageRed{session}(1, timepoints) = nanmean(color(timepoints, :));
                    averageRedCombined{session}(ss, timepoints) = nanmean(color(timepoints, :));
                    semRed{session}(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
                end
            end
        end
        pipr{session} = averageBlue{session}-averageRed{session};
        % calculate SEM for pipr
        for timepoints = 1:length(pipr{session});
            semPipr{session}(1,timepoints) = (semBlue{session}(1,timepoints)^2 + semRed{session}(1,timepoints)^2)^(1/2);
        end
        piprCombined{session}(ss,:) = averageBlue{session}-averageRed{session};
        averageBlueCombined{session}(ss,:) = averageBlue{session};
        averageRedCombined{session}(ss,:) = averageRed{session};
        % now do the plotting per subject
        plotFig = figure;
        errBar(1,:) = semBlue{session}(1:(length(averageBlue{session})));
        errBar(2,:) = semBlue{session}(1:(length(averageBlue{session})));
        
        shadedErrorBar((1:length(averageBlue{session}))*0.02,averageBlue{session}*100, errBar*100, 'b', 1);
        hold on
        line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
        
        errBar(1,:) = semRed{session}(1:(length(averageRed{session})));
        errBar(2,:) = semRed{session}(1:(length(averageRed{session})));
        
        shadedErrorBar((1:length(averageRed{session}))*0.02,averageRed{session}*100, errBar*100, 'r', 1);
        
        errBar(1,:) = semPipr{session}(1:(length(pipr{session})));
        errBar(2,:) = semPipr{session}(1:(length(pipr{session})));
        
        shadedErrorBar((1:length(pipr{session}))*0.02,pipr{session}*-100, errBar*100, 'k', 1);
        xlabel('Time (s)');
        ylabel('Percent Change (%)');
        ylim([-60 20]);
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulsePIPR/AverageResponse', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
        close(plotFig);
    end % end loop over subjects
end

% Make group average plots
for session = 1:2;
    for timepoints = 1:length(averageBlueCombined{session});
        averageBlueCollapsed{session}(1,timepoints) = nanmean(averageBlueCombined{session}(:,timepoints));
        semBlueCollapsed{session}(1,timepoints) = nanstd(averageBlueCombined{session}(:,timepoints))/sqrt(size(averageBlueCombined{session},1));
        averageRedCollapsed{session}(1,timepoints) = nanmean(averageRedCombined{session}(:,timepoints));
        semRedCollapsed{session}(1,timepoints) = nanstd(averageRedCombined{session}(:,timepoints))/sqrt(size(averageRedCombined{session},1));
        piprCollapsed{session}(1,timepoints) = nanmean(piprCombined{session}(:,timepoints));
        semPiprCollapsed{session}(1,timepoints) = nanstd(piprCombined{session}(:,timepoints))/sqrt(size(piprCombined{session},1));
    end
    
    
    plotFig = figure;
    errBar(1,:) = semBlueCollapsed{session}(1:(length(averageBlueCollapsed{session})));
    errBar(2,:) = semBlueCollapsed{session}(1:(length(averageBlueCollapsed{session})));
    
    shadedErrorBar((1:length(averageBlueCollapsed{session}))*0.02,averageBlueCollapsed{session}*100, errBar*100, 'b', 1);
    hold on
    line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
    errBar(1,:) = semRedCollapsed{session}(1:(length(averageRedCollapsed{session})));
    errBar(2,:) = semRedCollapsed{session}(1:(length(averageRedCollapsed{session})));
    
    shadedErrorBar((1:length(averageRedCollapsed{session}))*0.02,averageRedCollapsed{session}*100, errBar*100, 'r', 1);
    
    errBar(1,:) = semPiprCollapsed{session}(1:(length(piprCollapsed{session})));
    errBar(2,:) = semPiprCollapsed{session}(1:(length(piprCollapsed{session})));
    
    shadedErrorBar((1:length(piprCollapsed{session}))*0.02,piprCollapsed{session}*-100, errBar*100, 'k', 1);
    line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
    xlabel('Time (s)');
    ylabel('Percent Change (%)');
    ylim([-60 20]);
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
    close(plotFig);
end


%% Create plots across subjects that show the average response to the melanopsin and LMS stimuli
for session = 1:2;
    for ss = 1:size(goodSubjects{session}{1},1);
        subject = goodSubjects{session}{1}(ss,:);
        numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulsePIPR', subject));
        numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
        
        date = goodSubjects{session}{2}(ss,:);

        lms = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulseLMS', subject, date, [subject, '_PupilPulseData_MaxLMS_TimeSeries.csv']));
        mel = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_LongPulseMel', subject, date, [subject, '_PupilPulseData_MaxMel_TimeSeries.csv']));
        % create average pupil response for a given subject to the red or blue
        % stimulus
        for stimuli = 1:2;
            if stimuli == 1;
                color = lms;
            elseif stimuli == 2;
                color = mel;
            end
            for timepoints = 1:length(color);
                if stimuli == 1;
                    averageLMS{session}(1, timepoints) = nanmean(color(timepoints, :));
                    semLMS{session}(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
                    averageLMSCombined{session}(ss, timepoints) = nanmean(color(timepoints, :));
                elseif stimuli == 2;
                    averageMel{session}(1, timepoints) = nanmean(color(timepoints, :));
                    averageMelCombined{session}(ss, timepoints) = nanmean(color(timepoints, :));
                    semMel{session}(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
                end
            end
        end
        % now do the plotting per subject
        % first lms plots
        plotFig = figure;
        errBar(1,:) = semLMS{session}(1:(length(averageLMS{session})));
        errBar(2,:) = semLMS{session}(1:(length(averageLMS{session})));
        
        shadedErrorBar((1:length(averageLMS{session}))*0.02,averageLMS{session}*100, errBar*100, 'b', 1);
        hold on
        line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
        
        xlabel('Time (s)');
        ylabel('Percent Change (%)');
        ylim([-60 20]);
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulseLMS/AverageResponse', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
        close(plotFig);
        
        % now mel plots
        plotFig = figure;
        errBar(1,:) = semMel{session}(1:(length(averageMel{session})));
        errBar(2,:) = semMel{session}(1:(length(averageMel{session})));
        
        shadedErrorBar((1:length(averageMel{session}))*0.02,averageMel{session}*100, errBar*100, 'b', 1);
        hold on
        
        
        xlabel('Time (s)');
        ylabel('Percent Change (%)');
        ylim([-60 20]);
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulseMel/AverageResponse', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
        close(plotFig);
    end % end loop over subjects
end % end loop over sessions


% Make group average plots
for session = 1:2;
for timepoints = 1:length(averageLMSCombined{session});
    averageLMSCollapsed{session}(1,timepoints) = nanmean(averageLMSCombined{session}(:,timepoints));
    semLMSCollapsed{session}(1,timepoints) = nanstd(averageLMSCombined{session}(:,timepoints))/sqrt(size(averageLMSCombined{session},1));
    averageMelCollapsed{session}(1,timepoints) = nanmean(averageMelCombined{session}(:,timepoints));
    semMelCollapsed{session}(1,timepoints) = nanstd(averageMelCombined{session}(:,timepoints))/sqrt(size(averageMelCombined{session},1));
    
end

% first LMS
plotFig = figure;
errBar(1,:) = semLMSCollapsed{session}(1:(length(averageLMSCollapsed{session})));
errBar(2,:) = semLMSCollapsed{session}(1:(length(averageLMSCollapsed{session})));

shadedErrorBar((1:length(averageLMSCollapsed{session}))*0.02,averageLMSCollapsed{session}*100, errBar*100, 'b', 1);
hold on
line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');

xlabel('Time (s)');
ylabel('Percent Change (%)');
ylim([-60 20]);
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulseLMS/AverageResponse', num2str(session));
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
close(plotFig);

% now mel
plotFig = figure;
errBar(1,:) = semMelCollapsed{session}(1:(length(averageMelCollapsed{session})));
errBar(2,:) = semMelCollapsed{session}(1:(length(averageMelCollapsed{session})));

shadedErrorBar((1:length(averageMelCollapsed{session}))*0.02,averageMelCollapsed{session}*100, errBar*100, 'b', 1);
hold on
line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');

xlabel('Time (s)');
ylabel('Percent Change (%)');
ylim([-60 20]);
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulseMel/AverageResponse', num2str(session));
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
close(plotFig);

% putting LMS and Mel average response on the same plot
plotFig = figure;
errBar(1,:) = semLMSCollapsed{session}(1:(length(averageLMSCollapsed{session})));
errBar(2,:) = semLMSCollapsed{session}(1:(length(averageLMSCollapsed{session})));

shadedErrorBar((1:length(averageLMSCollapsed{session}))*0.02,averageLMSCollapsed{session}*100, errBar*100, 'm', 1);


xlabel('Time (s)');
ylabel('Percent Change (%)');
ylim([-60 20]);
hold on
line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
errBar(1,:) = semMelCollapsed{session}(1:(length(averageMelCollapsed{session})));
errBar(2,:) = semMelCollapsed{session}(1:(length(averageMelCollapsed{session})));

shadedErrorBar((1:length(averageMelCollapsed{session}))*0.02,averageMelCollapsed{session}*100, errBar*100, 'c', 1);


xlabel('Time (s)');
ylabel('Percent Change (%)');
ylim([-60 20]);
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_LongPulseLMS/AverageResponse', num2str(session));
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['LMSAndMel.png']), 'png');
close(plotFig);
end


end % end function
