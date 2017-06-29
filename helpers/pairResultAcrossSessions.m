function [ pairedResult ]  = pairResultAcrossSessions(goodSubjects, sessionOneResult, sessionTwoResult)

pairedResult{1} = [];
pairedResult{2} = [];

for ss = 1:size(goodSubjects{2}{1},1) % loop over subjects that have completed both sessions
    subject = goodSubjects{2}{1}(ss,:);
    
    secondSessionIndex = ss;
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    for x = 1:size(goodSubjects{1}{1},1)
        if strcmp(goodSubjects{1}{1}(x,:),subject);
            firstSessionIndex = x;
        end
    end
    
    pairedResult{1}(ss) = sessionOneResult(firstSessionIndex,:);
    pairedResult{2}(ss) = sessionTwoResult(secondSessionIndex,:);
   
end