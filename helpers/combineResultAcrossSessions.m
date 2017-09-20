function [ combinedResult ] = combineResultAcrossSessions(goodSubjects, sessionOneResult, sessionTwoResult)

% method for combining results across sessions
% - for subjects that have been scanned twice, the combined result is the average of those two measurements
% - for subjects that have been scanned once, the combined result is simply that single value


% first average datapoints for subjects who have been studied twice
for ss = 1:length(goodSubjects{2}.ID) % loop over subjects that have completed both sessions
    subject = goodSubjects{2}.ID{ss};
    
    secondSessionIndex = ss;
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    whichSubject = cellfun(@(x) strcmp(x, subject), goodSubjects{1}.ID);
    [maxValue, firstSessionIndex] = max(whichSubject);
    
    % actually do the averaging
    combinedResult(ss) = (sessionOneResult(firstSessionIndex) + sessionTwoResult(secondSessionIndex))/2;
end

% now append to the combineResults variable subjects who have only been studied once    
    
% variable for subject indices not scanned twice
notScannedTwice = [];

for ss = 1:length(goodSubjects{1}.ID)
    scannedTwice = 0;
    for ss2 = 1:length(goodSubjects{2}.ID)
        if strcmp(goodSubjects{1}.ID{ss}, goodSubjects{2}.ID{ss2})
            scannedTwice = 1;
        end
    end
    if scannedTwice == 0
        notScannedTwice = [notScannedTwice, ss];
    end
end

for ss = 1:size(notScannedTwice,2)
    combinedResult(length(goodSubjects{2}.ID)+ss) = sessionOneResult(notScannedTwice(ss));
end
