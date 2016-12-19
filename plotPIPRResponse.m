function [theResult] = plotPIPRResponse()

% Function to plot the average PIPR response
% First, we determine which subjects can be kept for the analysis because
% they do not mean exclusion criteria
% Second, we plot the average pupil response to blue stimulation, red
% stimulation, and the subtracted PIPR response
% Finally plots a group average

% 12/12/2016, written by hmm


%% Setup basic variables
% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/');
subAnalysisDirectory = 'PIPRMaxPulse_PulsePIPR/PIPRAverageResponse';

% Obtain list of subjects. Dynanmically figures out who the subjects are
% based on the contents of the PIPRMaxPulse_PulsePIPR folder
subjectList = [];
dirSubjectList = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR'));
% remove first two entries, which are "." and ".."
dirSubjectList = dirSubjectList(3:length(dirSubjectList));
for ss = 1:length(dirSubjectList);
    name = dirSubjectList(ss).name;
    % only include MELA subjects, not TEST subjects
    firstFour = dirSubjectList(ss).name(1:4);
    if strcmp(firstFour, 'MELA');
        subjectList = [subjectList; name];
    end
end

%% First, determine which subjects had data of high enough quality to avoid exclusion criteria
% For each subject, we're going to read in the subject's corresponding
% DataQuality.csv file which contains information about number of accepted
% vs. rejected trials
% Exclusion criteria, from the pre-registration document:
% ?	If, over all trials (PIPR, Mel, LMS), more than 50% of trials are identified as ?incomplete?
% ?	If, within a given trial block (PIPR, Mel, or LMS) more than 75% of trials are identified as ?incomplete?.

blockTypes = {'PIPR', 'Mel', 'LMS'};
goodSubjects = [];
badSubjects = [];

for ss = 1:length(subjectList);
    subject = subjectList(ss,:);
    % if failurePotential =/= 0, that means this subject meets exclusion
    % criteria and will be discarded
    failurePotential = 0;
    totalFailedTrials = 0;
    totalTrials = 0;
    for bb = 1:length(blockTypes)
        blockFailedTrials = 0;
        blockTotalTrials = 0;
        dataQualityCSV = importdata(fullfile(dropboxAnalysisDir, ['PIPRMaxPulse_Pulse', blockTypes{bb}], subject, [subject, '_PupilPulseData_DataQuality.csv']));
        trialTypes = size(dataQualityCSV.data,1)-1;
        for tt = 1:trialTypes;
            % keep track of total number of trials
            totalTrials = totalTrials + dataQualityCSV.data(tt,2);
            % keep track of total number of trials within a given block
            blockTotalTrials = blockTotalTrials + dataQualityCSV.data(tt,2);
            % keep track of total number of failed trials
            totalFailedTrials = totalFailedTrials + dataQualityCSV.data(tt,1);
            % keep track of total number of failed trials within a given
            % block
            blockFailedTrials = blockFailedTrials + dataQualityCSV.data(tt,1);
        end
        if blockFailedTrials/blockTotalTrials > 0.75;
            failurePotential = failurePotential + 1;
        end
    end
    if totalFailedTrials/totalTrials > 0.50;
        failurePotential = failurePotential +1;
    end
    if failurePotential == 0;
        goodSubjects = [goodSubjects; subject];
    end
    if failurePotential ~= 0;
        badSubjects = [badSubjects; subject];
    end
end


%% Create plots across subjects that show the average response to the red
%% stimulus, the blue stimulus, and the blue-red response
for ss = 1:length(goodSubjects);
    subject = goodSubjects(ss,:);
    blue = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
    red = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
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
                averageBlue(1, timepoints) = nanmean(color(timepoints, :));
                semBlue(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
                averageBlueCombined(ss, timepoints) = nanmean(color(timepoints, :));
            elseif stimuli == 2;
                averageRed(1, timepoints) = nanmean(color(timepoints, :));
                averageRedCombined(ss, timepoints) = nanmean(color(timepoints, :));
                semRed(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
            end
        end
    end
    pipr = averageBlue-averageRed;
    % calculate SEM for pipr
    for timepoints = 1:length(pipr);
        semPipr(1,timepoints) = (semBlue(1,timepoints)^2 + semRed(1,timepoints)^2)^(1/2);
    end
    piprCombined(ss,:) = averageBlue-averageRed;
    % now do the plotting per subject
    plotFig = figure;
    errBar(1,:) = semBlue(1:(length(averageBlue)));
    errBar(2,:) = semBlue(1:(length(averageBlue)));
    
    shadedErrorBar(1:length(averageBlue),averageBlue*100, errBar*100, 'b', 1);
    hold on
    
    errBar(1,:) = semRed(1:(length(averageRed)));
    errBar(2,:) = semRed(1:(length(averageRed)));
    
    shadedErrorBar(1:length(averageRed),averageRed*100, errBar*100, 'r', 1);
    
    errBar(1,:) = semPipr(1:(length(pipr)));
    errBar(2,:) = semPipr(1:(length(pipr)));
    
    shadedErrorBar(1:length(pipr),pipr*-100, errBar*100, 'k', 1);
    xlabel('Time (msec)');
    ylabel('Percent Change (%)');
    outDir = fullfile(dropboxAnalysisDir,subAnalysisDirectory);
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
    close(plotFig);
end % end loop over subjects

% Make group average plots
for timepoints = 1:length(averageBlueCombined);
    averageBlueCollapsed(1,timepoints) = nanmean(averageBlueCombined(:,timepoints));
    semBlueCollapsed(1,timepoints) = nanstd(averageBlueCombined(:,timepoints))/sqrt(size(averageBlueCombined,1));
    averageRedCollapsed(1,timepoints) = nanmean(averageRedCombined(:,timepoints));
    semRedCollapsed(1,timepoints) = nanstd(averageRedCombined(:,timepoints))/sqrt(size(averageRedCombined,1));
    piprCollapsed(1,timepoints) = nanmean(piprCombined(:,timepoints));
    semPiprCollapsed(1,timepoints) = nanstd(piprCombined(:,timepoints))/sqrt(size(piprCombined,1));
end


plotFig = figure;
errBar(1,:) = semBlueCollapsed(1:(length(averageBlueCollapsed)));
errBar(2,:) = semBlueCollapsed(1:(length(averageBlueCollapsed)));

shadedErrorBar(1:length(averageBlueCollapsed),averageBlueCollapsed*100, errBar*100, 'b', 1);
hold on

errBar(1,:) = semRedCollapsed(1:(length(averageRedCollapsed)));
errBar(2,:) = semRedCollapsed(1:(length(averageRedCollapsed)));

shadedErrorBar(1:length(averageRedCollapsed),averageRedCollapsed*100, errBar*100, 'r', 1);

errBar(1,:) = semPiprCollapsed(1:(length(piprCollapsed)));
errBar(2,:) = semPiprCollapsed(1:(length(piprCollapsed)));

shadedErrorBar(1:length(piprCollapsed),piprCollapsed*-100, errBar*100, 'k', 1);
xlabel('Time (msec)');
ylabel('Percent Change (%)');
outDir = fullfile(dropboxAnalysisDir,subAnalysisDirectory);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
close(plotFig);

%% Create plots across subjects that show the average response to the melanopsin and LMS stimuli
for ss = 1:length(goodSubjects);
    subject = goodSubjects(ss,:);
    lms = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseLMS', subject, [subject, '_PupilPulseData_MaxLMS_TimeSeries.csv']));
    mel = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseMel', subject, [subject, '_PupilPulseData_MaxMel_TimeSeries.csv']));
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
                averageLMS(1, timepoints) = nanmean(color(timepoints, :));
                semLMS(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
                averageLMSCombined(ss, timepoints) = nanmean(color(timepoints, :));
            elseif stimuli == 2;
                averageMel(1, timepoints) = nanmean(color(timepoints, :));
                averageMelCombined(ss, timepoints) = nanmean(color(timepoints, :));
                semMel(1,timepoints)  = nanstd(color(timepoints, :))/sqrt((size(color,2)));
            end
        end
    end
    % now do the plotting per subject
    % first lms plots
    plotFig = figure;
    errBar(1,:) = semLMS(1:(length(averageLMS)));
    errBar(2,:) = semLMS(1:(length(averageLMS)));
    
    shadedErrorBar(1:length(averageLMS),averageLMS*100, errBar*100, 'b', 1);
    hold on
    
    
    xlabel('Time (msec)');
    ylabel('Percent Change (%)');
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseLMS/AverageResponse');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
    close(plotFig);
    
    % now mel plots
    plotFig = figure;
    errBar(1,:) = semMel(1:(length(averageMel)));
    errBar(2,:) = semMel(1:(length(averageMel)));
    
    shadedErrorBar(1:length(averageMel),averageMel*100, errBar*100, 'b', 1);
    hold on
    
    
    xlabel('Time (msec)');
    ylabel('Percent Change (%)');
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseMel/AverageResponse');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
    close(plotFig);
end % end loop over subjects

% Make group average plots
for timepoints = 1:length(averageLMSCombined);
    averageLMSCollapsed(1,timepoints) = nanmean(averageLMSCombined(:,timepoints));
    semLMSCollapsed(1,timepoints) = nanstd(averageLMSCombined(:,timepoints))/sqrt(size(averageLMSCombined,1));
    averageMelCollapsed(1,timepoints) = nanmean(averageMelCombined(:,timepoints));
    semMelCollapsed(1,timepoints) = nanstd(averageMelCombined(:,timepoints))/sqrt(size(averageMelCombined,1));
    
end

% first LMS
plotFig = figure;
errBar(1,:) = semLMSCollapsed(1:(length(averageLMSCollapsed)));
errBar(2,:) = semLMSCollapsed(1:(length(averageLMSCollapsed)));

shadedErrorBar(1:length(averageLMSCollapsed),averageLMSCollapsed*100, errBar*100, 'b', 1);


xlabel('Time (msec)');
ylabel('Percent Change (%)');
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseLMS/AverageResponse');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
close(plotFig);

% now mel
plotFig = figure;
errBar(1,:) = semMelCollapsed(1:(length(averageMelCollapsed)));
errBar(2,:) = semMelCollapsed(1:(length(averageMelCollapsed)));

shadedErrorBar(1:length(averageMelCollapsed),averageMelCollapsed*100, errBar*100, 'b', 1);


xlabel('Time (msec)');
ylabel('Percent Change (%)');
outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseMel/AverageResponse');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
close(plotFig);

end % end function
