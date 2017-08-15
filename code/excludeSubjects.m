function [ goodSubjects, badSubjects ] = excludeSubjects(dropboxAnalysisDir)

dbstop if error

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

% output will be a goodSubjects, which is a 1x2 cell array. The first cell
% is the first session, the second cell is the second session. Within each
% session is also a 1x2 cell array. The first cell array will be all of the
% subject IDs, while the second cell array will be the corresponding dates
for session = 1:2;
    goodSubjects{session}{1} = [];
    goodSubjects{session}{2} = [];
    
    badSubjects{session} = [];
    badSubjects{session} = [];
end


for ss = 1:length(subjectList);
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
                goodSubjects{1}{1} = [goodSubjects{1}{1}; subject];
                goodSubjects{1}{2} = [goodSubjects{1}{2}; date];
                
            end
            if numberGoodSessions == 1;
                goodSubjects{2}{1} = [goodSubjects{2}{1}; subject];
                goodSubjects{2}{2} = [goodSubjects{2}{2}; date];
            end
            numberGoodSessions = numberGoodSessions + 1;
        end
        if failurePotential ~= 0;
            badSubjects{1} = [badSubjects{1}; subject];
            badSubjects{2} = [badSubjects{2}; date];
        end
        
        
        
        
    end % end loop over sessions
    
end % end loop over subjects

% addendum until we figure out a more elegant way to code this piece:
% -MELA_0037 on 12/06/2016: post experiment, both LMS and mel have very high splatter (200%) for just the first of 5 post-experiment validations -> but the other ones look great
% -MELA_0038 on 2/02/2017: for the mel validation, the first validation post-experiment also has very high S-splatter (-150%) -> but again, the other values look great
% so since these scans look like they're actually good, we'll just manually
% add them

%goodSubjects{2}{1} = [goodSubjects{2}{1}; 'MELA_0037'];
%goodSubjects{2}{2} = [goodSubjects{2}{2}; '120616'];


%goodSubjects{2}{1} = [goodSubjects{2}{1}; 'MELA_0038'];
%goodSubjects{2}{2} = [goodSubjects{2}{2}; '020217'];




end % end function