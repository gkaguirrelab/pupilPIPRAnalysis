function [ goodSubjects ] = excludeSubjects()

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

end % end function