function [ pairedResult ]  = pairResultAcrossSessions(goodSubjects, sessionOneResult, sessionTwoResult)

for ss = 1:length(goodSubjects{2}.ID) % loop over subjects that have completed both sessions
    subject = goodSubjects{2}.ID(ss);
    
    secondSessionIndex = ss;
    whichSubject = cellfun(@(x) strcmp(x, subject), goodSubjects{1}.ID);
    [maxValue, firstSessionIndex] = max(whichSubject);
    pairedResult.sessionOne(ss) = sessionOneResult(firstSessionIndex);
    pairedResult.sessionTwo(ss) = sessionTwoResult(secondSessionIndex);
   
end