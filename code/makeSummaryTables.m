function [dates, stimuli] = makeSummaryTables(goodSubjects)

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
