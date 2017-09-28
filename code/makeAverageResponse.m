function [averageResponsePerSubject, groupAverageResponse] = makeAverageResponse(goodSubjects, dropboxAnalysisDir, varargin)
% [averageResponsePerSubject, groupAverageResponse] = makeAverageResponse(goodSubjects, dropboxAnalysisDir, 'plot', 'on')

% This function to both calculate and plot the average  response for each
% subject for each stimulus type. The basic approach is to 1) figure out
% where the raw data lives for the given session, 2) compute the average
% and standard error of the mean for all timepoints across all trials, and
% 3) plot the results. These average responses are saved as output. Once
% the average responses for each subject are found, the average response
% across all subjects is determined for each session, for each stimulus
% type.

% Output:
%       averageResponsePerSubject: a cell array with each cell referring to
%           a session. The content of each cell array is a structure, with
%           subfields referring to the stimulus (as well as for the
%           standard error of the mean for that stimulus). The contents of
%           each subfield is a matrix, with each row referring to a
%           different subject. Each column is a timepoint containing the
%           average pupil diameter in units % change.
%       groupAverageResponse: same structure as the
%           averageResponsePerSubject, except the contents of each subfield
%           is a single vector. Each value of the vector is the average
%           pupil diameter across all subjects for that stimulus type.
%
% Input (required):
%       goodSubjects: list of subjects and associated dates when they were
%           studied
%       dropboxAnalysisDir: location of the directory where we can find the
%           data
%         
% Options:
%       'makePlots': if set to true, plots of the average responses will be
%       displayed and saved


% 9/28/2017: hmm added comments
% 9/20/2017: updated by hmm to new averageResponsePerSubject structure
% 12/12/2016: written by hmm


%% Parse input
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('goodSubjects',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);

% Optional display and I/O params
p.addParameter('makePlots',true,@islogical);

% Parse and check the parameters
p.parse(goodSubjects, dropboxAnalysisDir, varargin{:});


%% Determine the average response across all trials for each subject for each stimulation type 
for session = 1:length(goodSubjects)
    % where to look for the raw data depends on which session
    if session == 1 || session == 2
        subdir = '';
    elseif session == 3
        subdir = 'Legacy/';
    end
    
    
    
    for ss = 1:length(goodSubjects{session}.ID)
        
        stimuli = {'LMS' 'Mel' 'Blue' 'Red'};
        
        for stimulus = 1:length(stimuli)
            % the names of the datafiles vary by stimulus type
            if strcmp(stimuli(stimulus), 'LMS')
                stimuliDir = 'PIPRMaxPulse_PulseLMS';
                csvName = '_PupilPulseData_MaxLMS_TimeSeries.csv';
            elseif strcmp(stimuli(stimulus), 'Mel')
                stimuliDir = 'PIPRMaxPulse_PulseMel';
                csvName = '_PupilPulseData_MaxMel_TimeSeries.csv';
            elseif strcmp(stimuli(stimulus), 'Blue')
                stimuliDir = 'PIPRMaxPulse_PulsePIPR';
                csvName = '_PupilPulseData_PIPRBlue_TimeSeries.csv';
            elseif strcmp(stimuli(stimulus), 'Red')
                stimuliDir = 'PIPRMaxPulse_PulsePIPR';
                csvName = '_PupilPulseData_PIPRRed_TimeSeries.csv';
            end
            
            subject = goodSubjects{session}.ID{ss};
            % find the relevant data directory
            numberSessions = dir(fullfile(dropboxAnalysisDir, subdir, subject));
            % determine how many sessions are contained within
            numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
            
            % determine the date of a session
            dateList = dir(fullfile(dropboxAnalysisDir, subdir, subject));
            dateList = dateList(~ismember({dateList.name},{'.','..', '.DS_Store'}));
            
            date = goodSubjects{session}.date{ss};
            
            % now actually grab the data that contains the responses from
            % all trials for this stimulus type
            responses = importdata(fullfile(dropboxAnalysisDir, subdir, stimuliDir, subject, date, [subject, csvName]));
            
            
            % now do the averaging across trials
            for timepoints = 1:length(responses)
                averageResponsePerSubject{session}.(stimuli{stimulus})(ss,timepoints) = nanmean(responses(timepoints,:));
                averageResponsePerSubject{session}.([stimuli{stimulus}, '_SEM'])(ss,timepoints) = nanstd(responses(timepoints, :))/sqrt((size(responses,2)));
                
            end
        end
        
        % perform a quick PIPR calculation, where we just subtract the red
        % average response from the blue average response
        averageResponsePerSubject{session}.PIPR = averageResponsePerSubject{session}.Blue - averageResponsePerSubject{session}.Red;
        averageResponsePerSubject{session}.PIPR_SEM = (averageResponsePerSubject{session}.Blue_SEM.^2 + averageResponsePerSubject{session}.Red_SEM.^2).^(1/2);
        
        
        % now do the plotting per subject
        if p.Results.makePlots
            timebase = 0:0.02:13.98;
            for stimulus = 1:(length(stimuli) - 1)
                if strcmp(stimuli(stimulus), 'Blue')
                    
                    
                    plotFig = figure;
                    
                    errBar(1,:) = averageResponsePerSubject{session}.Blue_SEM(ss,:);
                    errBar(2,:) = averageResponsePerSubject{session}.Blue_SEM(ss,:);
                    
                    
                    shadedErrorBar(timebase, averageResponsePerSubject{session}.Blue(ss,:)*100, errBar*100, 'lineProps', '-b');
                    hold on
                    line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
                    
                    errBar(1,:) = averageResponsePerSubject{session}.Blue_SEM(ss,:);
                    errBar(2,:) = averageResponsePerSubject{session}.Red_SEM(ss,:);
                    
                    shadedErrorBar(timebase,averageResponsePerSubject{session}.Red(ss,:)*100, errBar*100, 'lineProps', '-r');
                    
                    errBar(1,:) = averageResponsePerSubject{session}.PIPR_SEM(ss,:);
                    errBar(2,:) = averageResponsePerSubject{session}.PIPR_SEM(ss,:);
                    
                    shadedErrorBar(timebase,averageResponsePerSubject{session}.PIPR(ss,:)*-100, errBar*100, 'lineProps', '-k');
                    
                    plot(timebase, zeros(1, length(timebase)), '--', 'Color', 'k')
                    
                    xlabel('Time (s)');
                    ylabel('Percent Change (%)');
                    ylim([-60 20]);
                    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/averageResponse/PIPR', num2str(session));
                    if ~exist(outDir, 'dir')
                        mkdir(outDir);
                    end
                    saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
                    close(plotFig);
                else % plot LMS and Mel stuff here
                    plotFig = figure;
                    errBar(1,:) = averageResponsePerSubject{session}.([stimuli{stimulus}, '_SEM'])(ss,:);
                    errBar(2,:) = averageResponsePerSubject{session}.([stimuli{stimulus}, '_SEM'])(ss,:);
                    
                    shadedErrorBar(timebase,averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:)*100, errBar*100, 'lineProps', '-b');
                    
                    xlabel('Time (s)');
                    ylabel('Percent Change (%)');
                    ylim([-60 20]);
                    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/averageResponse/', stimuli{stimulus}, num2str(session));
                    if ~exist(outDir, 'dir')
                        mkdir(outDir);
                    end
                    saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
                    close(plotFig);
                end
            end % end if statements
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions

%% Make group average plots
for session = 1:length(goodSubjects)
    for stimulus = 1:length(stimuli)
        % do the averaging
        for timepoints = 1:size(averageResponsePerSubject{session}.(stimuli{stimulus}), 2)
            groupAverageResponse{session}.(stimuli{stimulus})(timepoints) = nanmean(averageResponsePerSubject{session}.(stimuli{stimulus})(:,timepoints));
            groupAverageResponse{session}.([stimuli{stimulus}, '_SEM'])(timepoints) = nanstd(averageResponsePerSubject{session}.(stimuli{stimulus})(:,timepoints))/sqrt(size(averageResponsePerSubject{session}.(stimuli{stimulus}), 1));
        end
    end
    
    if p.Results.makePlots
        timebase = 0:0.02:13.98;
        for stimulus = 1:(length(stimuli)-1)
            if strcmp(stimuli{stimulus}, 'Blue')
                plotFig = figure;
                hold on
                line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
                
                errBar(1,:) = groupAverageResponse{session}.Blue_SEM;
                errBar(2,:) = groupAverageResponse{session}.Blue_SEM;
                
                shadedErrorBar(timebase,groupAverageResponse{session}.Blue*100, errBar*100, 'lineProps', '-b');
        
                errBar(1,:) = groupAverageResponse{session}.Red_SEM;
                errBar(2,:) = groupAverageResponse{session}.Red_SEM;
                
                shadedErrorBar(timebase,groupAverageResponse{session}.Red*100, errBar*100, 'lineProps', '-r');
    
                errBar(1,:) = (groupAverageResponse{session}.Red_SEM.^2 + groupAverageResponse{session}.Blue_SEM.^2).^0.5;
                errBar(2,:) = errBar(1,:);
                
                shadedErrorBar(timebase,(groupAverageResponse{session}.Red*100 - groupAverageResponse{session}.Blue*100), errBar*100, 'lineProps', '-k');
                
                xlabel('Time (s)');
                    ylabel('Percent Change (%)');
                    ylim([-60 20]);
                
                outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/averageResponse/PIPR', num2str(session));
                if ~exist(outDir, 'dir')
                    mkdir(outDir);
                end
                saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
                close(plotFig)
            else
                plotFig = figure;
                hold on
                line([1 4], [15 15], 'LineWidth', 4, 'Color', 'k');
                errBar(1,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);
                errBar(2,:) = errBar(1,:);
                
                shadedErrorBar(timebase, groupAverageResponse{session}.(stimuli{stimulus})*100, errBar*100, 'lineProps', '-b')
            
                xlabel('Time (s)');
                    ylabel('Percent Change (%)');
                    ylim([-60 20]);
                
                outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/averageResponse/', stimuli{stimulus}, num2str(session));
                if ~exist(outDir, 'dir')
                    mkdir(outDir);
                end
                saveas(plotFig, fullfile(outDir, ['group.png']), 'png');
                close(plotFig)
            end
        
        
        end
    end
end % end loop over sessions
    
    
end % end function
