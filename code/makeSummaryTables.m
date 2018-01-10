function [dates, validationSummary] = makeSummaryTables(goodSubjects, dropboxAnalysisDir)

% maek date summary table
dates = [];
for ss = 1:length(goodSubjects{1}.ID)
    subject = goodSubjects{1}.ID(ss);
    date1 = goodSubjects{1}.date{ss};
    
    whichSubject = [];
    whichSubject = cellfun(@(x) strcmp(x, subject), goodSubjects{2}.ID);
    if sum(whichSubject) == 0
        date2 = '-';
    else
        [maxValue, maxIndex] = max(whichSubject);
        date2 = goodSubjects{2}.date{maxIndex};
    end
    
    whichSubject = [];
    whichSubject = cellfun(@(x) strcmp(x, subject), goodSubjects{3}.ID);
    if sum(whichSubject) == 0
        date3 = '-';
    else
        [maxValue, maxIndex] = max(whichSubject);
        date3 = goodSubjects{3}.date{maxIndex};
    end
    
    dates.(goodSubjects{1}.ID{ss}) =  [datenum(date1, 'mmddyy'), datenum(date2, 'mmddyy'), datenum(date3, 'mmddyy')];
   
    
end

% make the summary table of validation results

stimuli = {'Melanopsin', 'LMS', 'Red', 'Blue'};
counter = 1;

% some notes on the organization of this table: each row will be a single
% session from a single subject. The rows will be in the order of the
% goodSubjects{session}.ID/date. Session 1 first, then all of session 2
% next, then all of session 3 last. Basically goodSubjects has to serve as
% the key for the table.
for session = 1:3
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        
        [ passStatusSplatter, validation ] = analyzeValidation(subject, date, dropboxAnalysisDir, 'verbose', 'off', 'plot', 'off', 'whichValidation', 'post');
        for stimulus = 1:length(stimuli)
            if strcmp(stimuli{stimulus}, 'Melanopsin')

                validationSummary(counter, 1) = median([validation.Melanopsin.MelanopsinContrast]);
                validationSummary(counter, 2) = median([validation.Melanopsin.SConeContrast]);
                validationSummary(counter, 3) = median([validation.Melanopsin.LMinusMContrast]);
                validationSummary(counter, 4) = median([validation.Melanopsin.LMSContrast]);
                validationSummary(counter, 5) = median([validation.Melanopsin.backgroundLuminance]);
            elseif strcmp(stimuli{stimulus}, 'LMS')
                validationSummary(counter, 6) = median([validation.LMS.LMSContrast]);
                validationSummary(counter, 7) = median([validation.LMS.SConeContrast]);
                validationSummary(counter, 8) = median([validation.LMS.LMinusMContrast]);
                validationSummary(counter, 9) = median([validation.LMS.MelanopsinContrast]);
                validationSummary(counter, 10) = median([validation.LMS.backgroundLuminance]);
            elseif strcmp(stimuli{stimulus}, 'Red')
                validationSummary(counter, 11) = median([validation.Red.retinalIrradiance]);
                validationSummary(counter, 12) = median([validation.Red.backgroundLuminance]);
            elseif strcmp(stimuli{stimulus}, 'Blue')
                validationSummary(counter, 13) = median([validation.Blue.retinalIrradiance]);
                validationSummary(counter, 14) = median([validation.Blue.backgroundLuminance]);
            end
        end
        counter = counter + 1;
    end
end
                
end % end function
