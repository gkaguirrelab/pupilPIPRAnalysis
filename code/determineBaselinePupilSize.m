function [baselinePupilSize] = determineBaselinePupilSize(goodSubjects, dropboxAnalysisDir)

%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;
p.addRequired('goodSubjects',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);


% Optional analysis parameters
p.addParameter('stimulusLabels',{'LMS' 'Mel' 'Blue' 'Red'},@iscell);



%% Parse and check the parameters
p.parse(goodSubjects, dropboxAnalysisDir, varargin{:});


% a way to link the stimulus described in the stimuli vector above, with
% where that data lives (the blue and red are PIPR stimuli, and are located
% within the same folder.
stimuliType = {'LMS', 'Mel', 'PIPR', 'PIPR'};


for session = 1:length(goodSubjects)
    if session == 1 || session == 2
        subdir = '';
    elseif session == 3
        subdir = 'Legacy';
    end
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        fprintf(['Fitting subject %d, session %d. Started at ' char(datetime('now')), '\n'], ss, session)
        
        for stimulus = 1:length(p.Results.stimulusLabels)
            % determine where the raw data for each trial lives. this
            % depends on the stimulus
            csvFileName = dir(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, [subject, '*', p.Results.stimulusLabels{stimulus}, '_TimeSeries.csv']));
            csvFileName = csvFileName.name;
            
            
            
            
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions