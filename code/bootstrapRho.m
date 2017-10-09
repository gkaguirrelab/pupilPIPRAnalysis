function [ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, firstSessionResult, secondSessionResult, dropboxAnalysisDir)

% if the firstSessionResult and the secondSessionResult are not of the same
% length, then we assume they have to be paired using the function
% pairResultAcrossSessions
if length(firstSessionResult) ~= length(secondSessionResult)
    [resultCombined] = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, firstSessionResult, secondSessionResult, dropboxAnalysisDir, 'makePlot', false);
else
    resultCombined.sessionOne = firstSessionResult;
    resultCombined.sessionTwo = secondSessionResult;
end

% do the bootstrapping
nBootstraps = 10000;

for bb = 1:nBootstraps
    % grab a list of subjects, with replacement
    nSubjects = 24;
    randomSubjects = randsample(1:nSubjects, nSubjects, true);
    
    rho = corr(resultCombined.sessionOne(randomSubjects)', resultCombined.sessionTwo(randomSubjects)', 'type', 'Spearman');
    rhoCombined(bb) = rho;
end

% now determine the 95% confidence interval:
% leaving this for legacy purposes, but isn't the ideal way to calculate
% the 95% confidence interval for correlation data (data aren't normally
% distributed and are instead bound between -1 and 1)
%SEM = std(rhoCombined);
%tScore = tinv([0.025 0.975], length(rhoCombined)-1);
%confidenceInterval = mean(rhoCombined) + tScore*SEM
%meanRho = mean(rhoCombined)


% now determine the 95% confidence interval
sortedRho = sort(rhoCombined);
confidenceInterval(1) = sortedRho(501);
confidenceInterval(2) = sortedRho(9501);
meanRho = mean(rhoCombined);