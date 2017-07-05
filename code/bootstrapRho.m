function [ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, amplitudes)

% combine the melanopsin-specific response index for subjects who have completed both sessions
[melNormedCombined] = pairResultAcrossSessions(goodSubjects, amplitudes{1}(:,6), amplitudes{2}(:,6));

% do the bootstrapping
nBootstraps = 10000;

for bb = 1:nBootstraps
    % grab a list of subjects, with replacement
    nSubjects = 25;
    randomSubjects = randsample(1:nSubjects, nSubjects, true);
    
    rho = corr(melNormedCombined{1}(randomSubjects)', melNormedCombined{2}(randomSubjects)', 'type', 'Spearman');
    rhoCombined(bb) = rho;
end

% now determine the 95% confidence interval:
SEM = std(rhoCombined);
tScore = tinv([0.025 0.975], length(rhoCombined)-1);
confidenceInterval = mean(rhoCombined) + tScore*SEM
meanRho = mean(rhoCombined)
