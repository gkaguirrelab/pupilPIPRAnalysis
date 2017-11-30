function [ confidenceInterval ] = simulateRho(goodSubjects, distribution)

% This function uses the bootstrap distribution of TPUP model fit
% parameters to create a confidence interval of the rho value quantifying
% the reproducibility from one session with another. 

% simulate mel first
nSimulations = 1000;

for session = 1:3
    rhoAccumulator{session} = [];
    for nn = 1:nSimulations
        for ss = 1:length(goodSubjects{session}.ID)
            nSamples = length([distribution{session}.(goodSubjects{session}.ID{ss}).Mel.totalResponseArea]);
            randomDrawFirstSession = randi([1 nSamples]);
            firstSessionResult(ss) = distribution{session}.(goodSubjects{session}.ID{ss}).Mel(randomDrawFirstSession).totalResponseArea;
            randomDrawSecondSession = randi([1 nSamples]);
            secondSessionResult(ss) = distribution{session}.(goodSubjects{session}.ID{ss}).Mel(randomDrawSecondSession).totalResponseArea;
        end
        rho = corr(firstSessionResult', secondSessionResult', 'type', 'Spearman');
        rhoAccumulator{session} = [rhoAccumulator{session}, rho];
    end
end

% determine 95% confidence interval on the basis of these bootstrap
% simulations

for session = 1:3
    sortedRho = sort(rhoAccumulator{session});
    confidenceInterval{session}.Mel.percentile975 = sortedRho(round(0.975*nSimulations));
    confidenceInterval{session}.Mel.percentile95 = sortedRho(round(0.95*nSimulations));
    confidenceInterval{session}.Mel.percentile90 = sortedRho(round(0.90*nSimulations));
    confidenceInterval{session}.Mel.percentile10 = sortedRho(round(0.10*nSimulations));
    confidenceInterval{session}.Mel.percentile05 = sortedRho(round(0.05*nSimulations));
    confidenceInterval{session}.Mel.percentile025 = sortedRho(round(0.025*nSimulations));
end

%% now for LMS pulses
for session = 1:3
    rhoAccumulator{session} = [];
    for nn = 1:nSimulations
        for ss = 1:length(goodSubjects{session}.ID)
            nSamples = length([distribution{session}.(goodSubjects{session}.ID{ss}).LMS.totalResponseArea]);
            randomDrawFirstSession = randi([1 nSamples]);
            firstSessionResult(ss) = distribution{session}.(goodSubjects{session}.ID{ss}).LMS(randomDrawFirstSession).totalResponseArea;
            randomDrawSecondSession = randi([1 nSamples]);
            secondSessionResult(ss) = distribution{session}.(goodSubjects{session}.ID{ss}).LMS(randomDrawSecondSession).totalResponseArea;
        end
        rho = corr(firstSessionResult', secondSessionResult', 'type', 'Spearman');
        rhoAccumulator{session} = [rhoAccumulator{session}, rho];
    end
end

% determine 95% confidence interval on the basis of these bootstrap
% simulations

for session = 1:3
    sortedRho = sort(rhoAccumulator{session});
    confidenceInterval{session}.LMS.percentile975 = sortedRho(round(0.975*nSimulations));
    confidenceInterval{session}.LMS.percentile95 = sortedRho(round(0.95*nSimulations));
    confidenceInterval{session}.LMS.percentile90 = sortedRho(round(0.90*nSimulations));
    confidenceInterval{session}.LMS.percentile10 = sortedRho(round(0.10*nSimulations));
    confidenceInterval{session}.LMS.percentile05 = sortedRho(round(0.05*nSimulations));
    confidenceInterval{session}.LMS.percentile025 = sortedRho(round(0.025*nSimulations));
end

end