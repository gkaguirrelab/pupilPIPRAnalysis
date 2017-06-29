function [ combinedResult ] = combineResultAcrossSessions(goodSubjects, sessionOneResult, sessionTwoResult)


% first average datapoints for subjects who have been studied twice
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
    
    % actually do the averaging
    combinedResult(ss) = (sessionOneResult(firstSessionIndex) + sessionTwoResult(secondSessionIndex))/2;
end

% now append to the combineResults variable subjects who have only been studied once    
    
% variable for subject indices not scanned twice
notScannedTwice = [];

for ss = 1:size(goodSubjects{1}{1},1)
    scannedTwice = 0;
    for ss2 = 1:size(goodSubjects{2}{1},1)
        if strcmp(goodSubjects{1}{1}(ss,:), goodSubjects{2}{1}(ss2,:))
            scannedTwice = 1;
        end
    end
    if scannedTwice == 0
        notScannedTwice = [notScannedTwice, ss];
    end
end

for ss = 1:size(notScannedTwice,2)
    combinedResult(size(goodSubjects{2}{1},1)+ss) = sessionOneResult(notScannedTwice(ss));
end
