function [ goodSubjects, badSubjects ] = excludeSubjects(dropboxAnalysisDir)

dbstop if error

% Obtain list of subjects for the first two sessions. Dynanmically figures out who the subjects are
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


%% First, determine which subjects had data of high enough quality to avoid exclusion criteria for the first two sessions
% For each subject, we're going to read in the subject's corresponding
% DataQuality.csv file which contains information about number of accepted
% vs. rejected trials
% Exclusion criteria, from the pre-registration document:
% ?	If, over all trials (PIPR, Mel, LMS), more than 50% of trials are identified as ?incomplete?
% ?	If, within a given trial block (PIPR, Mel, or LMS) more than 75% of trials are identified as ?incomplete?.

% output will be a goodSubjects, which is a 1x3 cell array. The first cell
% is the first session, the second cell is the second session, the third cell for the third session. Within each
% session there are two subfields, subject ID (eg 'MELA_0078') and date (eg '081017'). 
for session = 1:3;

    goodSubjects{session}.ID = [];
    goodSubjects{session}.date = [];
    
    badSubjects.ID = [];
    badSubjects.date = [];
  
end



%% this loop accumulates subjects who have finished one or two sessions.
% the basic logic is: for each subject within the MELA_analysis/PIPRMaxPulsePIPR
% directory, check each session if it passes our inclusion criteria
% the earliest session to pass inclusion criteria becomes subject, the
% second session that passes inclusion criteria becomes the second session

for ss = 1:size(subjectList,1)
    subject = subjectList(ss,:);
    % determine if a subject has done one or two sessions
    numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
    numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
    
    numberGoodSessions = 0;
    for session = 1:numberSessions;
        % if failurePotential =/= 0, that means this subject meets exclusion
        % criteria and will be discarded
        
        % determine the date of a session
        dateList = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        dateList = dateList(~ismember({dateList.name},{'.','..', '.DS_Store'}));
        
        
        
        date = dateList(numberSessions - session + 1).name;
        
        % we don't have the same validation procedure prior to 092916, so
        % assume everyone has good splatter prior to this date
        if datenum(date, 'mmddyy') > datenum('092916', 'mmddyy')
            [ passStatusSplatter ] = analyzeValidation(subject, date, dropboxAnalysisDir, 'verbose', 'off', 'plot', 'off');
        else
            passStatusSplatter = 1;
        end
        
        [ passStatusDataQuality ] = analyzeDataQuality(subject, date, dropboxAnalysisDir, 'verbose', 'off');
        
        if passStatusSplatter == 1 && passStatusDataQuality == 1
            failurePotential = 0;
        else
            failurePotential = 1;
        end
        
        if failurePotential == 0;
            if numberGoodSessions == 0;
                goodSubjects{1}.ID = [goodSubjects{1}.ID cellstr(subject)];
                goodSubjects{1}.date = [goodSubjects{1}.date cellstr(date)];
            end
            if numberGoodSessions == 1;
                goodSubjects{2}.ID = [goodSubjects{2}.ID cellstr(subject)];
                goodSubjects{2}.date = [goodSubjects{2}.date cellstr(date)];
            end
            numberGoodSessions = numberGoodSessions + 1;
        end
        if failurePotential ~= 0;
            badSubjects.ID = [badSubjects.ID cellstr(subject)];
            badSubjects.date = [badSubjects.date cellstr(date)];
        end
        
        
        
        
    end % end loop over sessions
    
end % end loop over subjects

%% In this part, we're going to accumulate subjects who have completed a third session
% the basic logic is going to be in the same: for each subject listed
% within MELA_analysis/Legacy/PIPRMaxPulse_PIPR, determine number of
% potential sessions. Of the potential sessions, determine which one passes
% inclusion criteria, and add it to our list

% Obtain list of subjects for the third session. Dynanmically figures out who the subjects are
% based on the contents of the PIPRMaxPulse_PulsePIPR folder
subjectList = [];
dirSubjectList = dir(fullfile(dropboxAnalysisDir, 'Legacy/PIPRMaxPulse_PulsePIPR'));
% remove first three entries, which are "." , "..", and .DS_Store
dirSubjectList = dirSubjectList(4:length(dirSubjectList));
for ss = 1:length(dirSubjectList);
    name = dirSubjectList(ss).name;
    % only include MELA subjects, not TEST subjects
    firstFour = dirSubjectList(ss).name(1:4);
    if strcmp(firstFour, 'MELA');
        subjectList = [subjectList; name];
    end
end

for ss = 1:size(subjectList,1)
    subject = subjectList(ss,:);
    % determine if a subject has done one or two sessions
    numberSessions = dir(fullfile(dropboxAnalysisDir, 'Legacy/PIPRMaxPulse_PulsePIPR', subject));
    numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
    
    
    for session = 1:numberSessions;
        % if failurePotential =/= 0, that means this subject meets exclusion
        % criteria and will be discarded
        
        % determine the date of a session
        dateList = dir(fullfile(dropboxAnalysisDir, 'Legacy/PIPRMaxPulse_PulsePIPR', subject));
        dateList = dateList(~ismember({dateList.name},{'.','..', '.DS_Store'}));
        
        
        
        date = dateList(numberSessions - session + 1).name;
        
        % we don't have the same validation procedure prior to 092916, so
        % assume everyone has good splatter prior to this date
        if datenum(date, 'mmddyy') > datenum('092916', 'mmddyy')
            [ passStatusSplatter ] = analyzeValidation(subject, date, dropboxAnalysisDir, 'verbose', 'off', 'plot', 'off');
        else
            passStatusSplatter = 1;
        end
        
        [ passStatusDataQuality ] = analyzeDataQuality(subject, date, dropboxAnalysisDir, 'verbose', 'off');
        
        if passStatusSplatter == 1 && passStatusDataQuality == 1
            failurePotential = 0;
        else
            failurePotential = 1;
        end
        
        if failurePotential == 0;
            
                goodSubjects{3}.ID = [goodSubjects{3}.ID cellstr(subject)];
                goodSubjects{3}.date = [goodSubjects{3}.date cellstr(date)];
        end
        if failurePotential ~= 0;
            badSubjects.ID = [badSubjects.ID cellstr(subject)];
            badSubjects.date = [badSubjects.date cellstr(date)];
        end
    end % end loop over sessions
end % end loop over subjects

end % end function