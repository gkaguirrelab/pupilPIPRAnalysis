function [baselinePupilSize] = analyzeBaselinePupilSize(goodSubjects, dropboxAnalysisDir, varargin)

%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;
p.addRequired('goodSubjects',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);


% Optional analysis parameters
p.addParameter('stimulusLabels',{'LMS' 'Mel' 'Blue' 'Red'},@iscell);
p.addParameter('whichTrials','all',@ischar);



%% Parse and check the parameters
p.parse(goodSubjects, dropboxAnalysisDir, varargin{:});


% a way to link the stimulus described in the stimuli vector above, with
% where that data lives (the blue and red are PIPR stimuli, and are located
% within the same folder.
stimuliType = {'LMS', 'Mel', 'PIPR'};


for session = 1:length(goodSubjects)
    if session == 1 || session == 2
        subdir = '';
    elseif session == 3
        subdir = 'Legacy';
    end
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        
        for stimulus = 1:length(stimuliType)
            % determine where the raw data for each trial lives. this
            % depends on the stimulus
            csvFileName = dir(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, [subject, '_PupilPulseData_Background_Mean.csv']));
            csvFileName = csvFileName.name;
            
            allTrials = [];
            allTrials = importdata(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, csvFileName));
            if strcmp(p.Results.whichTrials, 'all')
                whichTrials = 1:length(allTrials);
            elseif strcmp(p.Results.whichTrials, 'last')
                whichTrials = length(allTrials);
            end
            baselinePupilSize{session}.(stimuliType{stimulus})(ss) = nanmean(allTrials(whichTrials));
            
            
            
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions

%% now do some plotting to summarize

plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuliType)
    
    
    subplot(1,3,stimulus)
    pbaspect([1 1 1])
    title(stimuliType{stimulus});
    
    data = {baselinePupilSize{1}.(stimuliType{stimulus})', baselinePupilSize{2}.(stimuliType{stimulus})', baselinePupilSize{3}.(stimuliType{stimulus})'};
    plotSpread(data,  'xNames', {'Session 1', 'Session 2', 'Session 3'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
end


plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuliType)
    
    
    subplot(1,3,stimulus)
    pbaspect([1 1 1])
    title(stimuliType{stimulus});
    
    [combinedBaselinePupilSize] = combineResultAcrossSessions(goodSubjects, baselinePupilSize{1}.(stimuliType{stimulus}), baselinePupilSize{2}.(stimuliType{stimulus}));
    
    data = {combinedBaselinePupilSize.result', baselinePupilSize{3}.(stimuliType{stimulus})'};
    plotSpread(data,  'xNames', {'Session 1/2', 'Session 3'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
end

end % end function