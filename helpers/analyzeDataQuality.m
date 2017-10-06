function [ passStatus ] = analyzeDataQuality(subject, date, dropboxAnalysisDir, varargin)

%% Parse input
p = inputParser; p.KeepUnmatched = true;

p.addParameter('verbose','off',@ischar);


p.parse(varargin{:});


%% first step is to see where the relevant data lives
% This is less straightforward because the first two sessions were collected within
% MELA_analysis folder, the third session is going within
% MELA_analysis/Legacy
if exist(fullfile(dropboxAnalysisDir, 'Legacy', 'PIPRMaxPulse_PulsePIPR', subject, date), 'dir')
    dropboxAnalysisDir = fullfile(dropboxAnalysisDir, 'Legacy');
elseif exist(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date), 'dir')
    dropboxAnalysisDir = dropboxAnalysisDir;
else
    sprintf('No Session Found for Given Subject (%s) at Given Date (%s)', subject, date)
    return
end


%% Now actually figure out the data quality for this session
blockTypes = {'PIPR', 'Mel', 'LMS'};

% set up counters for the entire session
failurePotential = 0;
totalFailedTrials = 0;
totalTrials = 0;

% loop over each block, PIPR, Mel, and LMS
for bb = 1:length(blockTypes)
    
    % set up counters for each block
    blockFailedTrials = 0;
    blockTotalTrials = 0;
    blockGoodTrials = 0;
    
    % load the dataQuality CSV file that tells about subject performance
    % and how many trials we had to discard within a block
    dataQualityCSV = importdata(fullfile(dropboxAnalysisDir, ['PIPRMaxPulse_Pulse', blockTypes{bb}], subject, date, [subject, '_PupilPulseData_DataQuality.csv']));
    trialTypes = size(dataQualityCSV.data,1)-1;
    
    % loop over trial types. For mel and LMS, this will equal 1 (all trials
    % within these blocks are the same). But for PIPR, this will be two
    % (red and blue) so we need to loop over an additional column.
    for tt = 1:trialTypes;
        % keep track of total number of trials
        totalTrials = totalTrials + dataQualityCSV.data(tt,2);
        % keep track of total number of trials within a given block
        blockTotalTrials = blockTotalTrials + dataQualityCSV.data(tt,2);
        
        % keep track of total number of failed trials
        %totalFailedTrials = totalFailedTrials + dataQualityCSV.data(tt,1);
        % keep track of total number of failed trials within a given
        % block
        %blockFailedTrials = blockFailedTrials + dataQualityCSV.data(tt,1);
        
        if strcmp(blockTypes{bb}, 'PIPR')
            if tt == 1 % blue
                csvFileName = dir(fullfile(dropboxAnalysisDir, ['PIPRMaxPulse_Pulse', blockTypes{bb}], subject, date, [subject, '*',  'Blue_TimeSeries.csv']));
            end
            if tt == 2 % red
                csvFileName = dir(fullfile(dropboxAnalysisDir, ['PIPRMaxPulse_Pulse', blockTypes{bb}], subject, date, [subject, '*',  'Red_TimeSeries.csv']));
                
            end
        else
            csvFileName = dir(fullfile(dropboxAnalysisDir, ['PIPRMaxPulse_Pulse', blockTypes{bb}], subject, date, [subject, '*', blockTypes{bb}, '_TimeSeries.csv']));
            
        end
        
        
        if length(csvFileName) == 0
            blockGoodTrials = 0;
        else
            csvFileName = csvFileName.name;
            % load the raw data
            allTrials = importdata(fullfile(dropboxAnalysisDir, ['PIPRMaxPulse_Pulse', blockTypes{bb}], subject, date, csvFileName));
            % determine number of trials
            numberTrials = size(allTrials,2);
            packetCellArray = [];
            
            %discard a trial if it is all NaNs, discard it
            for trial = 1:numberTrials
                packetCellArray{trial} = [];
            end
            for trial = 1:numberTrials
                if sum(isnan(allTrials(:,trial))) ~= 700
                    packetCellArray{trial}.response.values = allTrials(:,trial)';
                else
                    packetCellArray{trial} = [];
                    
                end
            end
            
            packetCellArray = packetCellArray(~cellfun('isempty',packetCellArray));
            
            
            
            blockGoodTrials = blockGoodTrials + length(packetCellArray);
        end
    end
    
    blockFailedTrials = blockTotalTrials - blockGoodTrials;
    
    if blockFailedTrials/blockTotalTrials > 0.75;
        failurePotential = failurePotential + 1;
        if strcmp(p.Results.verbose, 'on')
            sprintf('Subject failed %s block', blockTypes{bb})
        end
    end
    
end

if totalFailedTrials/totalTrials > 0.50;
    failurePotential = failurePotential +1;
    if strcmp(p.Results.verbose, 'on')
        
        sprintf('Subject failed >50 percent of trials across all blocks')
    end
end

% now apply failurePotential to determine passStatus.
% if failurePotential goes above 1, this subject has failed this session
if failurePotential > 0
    % so passStatus should indicate failure with 0
    passStatus = 0;
else
    % if no failure, passStatus should indicate success with 1
    passStatus = 1;
end

end % end function