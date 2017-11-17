function simulationForPowerAnalysis(goodSubjects, TPUPParameters)
% This function runs simulations in order to determine how much power we have to detect
% group differences. The simulations are based on our observed data. To
% make our experimental/sick group, we are applying a 33% reduction to the
% persistent amplitude component of the Mel response, based on the work by
% Joyce et al (https://www.biorxiv.org/content/early/2017/07/28/169946).
% For now, this function determines how power varies as a function of the
% number of subjects within each group, setting alpha and effect size as
% constant.


%% first we want to combine our sessions 1 and 2 so we have representative raw data to sample from
stimuli = {'LMS', 'Mel'};
amplitudeComponents = {'transientAmplitude', 'sustainedAmplitude', 'persistentAmplitude'};

for stimulus = 1:length(stimuli)
    for amplitude = 1:length(amplitudeComponents)
        [ combinedComponent ]  = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).(amplitudeComponents{amplitude}), TPUPParameters{2}.(stimuli{stimulus}).(amplitudeComponents{amplitude}));
        combinedTPUPParameters.(stimuli{stimulus}).(amplitudeComponents{amplitude}) = combinedComponent.result;
    end
end
%% set important variablers
alpha = 0.01;
effectSize = 1/3; % the idea we're running with for now is that the true effect of disease is a 33% reduction in the magnitude of the persistent component

%% as we vary the number of subjects, compute the power
for ii = 1:50
    nSubjects = ii;
    [power] = calculatePower(nSubjects, alpha, effectSize);
    powerAccumulator(ii) = power;
end

% plot to summarize
plotFig = figure;
plot(1:50, powerAccumulator)
xlabel('Number of Subjects')
ylabel('Power')
%% function that actually runs the simulations
function [power] = calculatePower(nSubjects, alpha, effectSize)
nSimulations = 10000;
pAccumulator = [];
for ss = 1:nSimulations
    % run single simulation
    % gather our sample
    controlSubjectIndices = randsample(1:length(combinedTPUPParameters.LMS.transientAmplitude), nSubjects, true);
    experimentalSubjectIndices = randsample(1:length(combinedTPUPParameters.LMS.transientAmplitude), nSubjects, true);
    
    % gather mel/lms response ratios for our control group
    %controlMeltoLMS = (combinedTPUPParameters.Mel.transientAmplitude(controlSubjectIndices) + combinedTPUPParameters.Mel.sustainedAmplitude(controlSubjectIndices) + combinedTPUPParameters.Mel.persistentAmplitude(controlSubjectIndices))./(combinedTPUPParameters.LMS.transientAmplitude(controlSubjectIndices) + combinedTPUPParameters.LMS.sustainedAmplitude(controlSubjectIndices) + combinedTPUPParameters.LMS.persistentAmplitude(controlSubjectIndices));
    
    % gather mel/lms response ratios for our experimental group
    % note here is how we're applying our effect size, from https://www.biorxiv.org/content/biorxiv/early/2017/07/28/169946.full.pdf
    % we're saying the consequence of disease is a 10% reduction in the
    % persistent amplitude for mel
    %experimentalMeltoLMS = (combinedTPUPParameters.Mel.transientAmplitude(experimentalSubjectIndices) + combinedTPUPParameters.Mel.sustainedAmplitude(experimentalSubjectIndices) + combinedTPUPParameters.Mel.persistentAmplitude(experimentalSubjectIndices)*(1-effectSize))./(combinedTPUPParameters.LMS.transientAmplitude(experimentalSubjectIndices) + combinedTPUPParameters.LMS.sustainedAmplitude(experimentalSubjectIndices) + combinedTPUPParameters.LMS.persistentAmplitude(experimentalSubjectIndices));
    % evaluate the significance of this group difference
    
    %[h, p] = ttest2(controlMeltoLMS, experimentalMeltoLMS, 'Tail', 'right');
    
    % below is a bit of code if instead of looking at the mel/lms response
    % ratio, just looking if the total response area for mel differs
    % between these two groups
    controlMel = abs((combinedTPUPParameters.Mel.transientAmplitude(controlSubjectIndices) + combinedTPUPParameters.Mel.sustainedAmplitude(controlSubjectIndices) + combinedTPUPParameters.Mel.persistentAmplitude(controlSubjectIndices)));
    experimentalMel = abs((combinedTPUPParameters.Mel.transientAmplitude(experimentalSubjectIndices) + combinedTPUPParameters.Mel.sustainedAmplitude(experimentalSubjectIndices) + combinedTPUPParameters.Mel.persistentAmplitude(experimentalSubjectIndices)*(1-effectSize)));
    [h, p] = ttest2(controlMel, experimentalMel, 'Tail', 'right');
    
    % stash the p value
    pAccumulator = [pAccumulator, p];
end

% on the basis of that distribution of probabilities, determine our power
power = sum(pAccumulator < alpha)/nSimulations;
end

%% so I don't forget, a summary of what I think this function should be doing
% what follows below is a single simulation
% [draw a sample of control subjects
% with replacement, grab 20 subjects from a list of 24 subjects
% store their mel/lms response ratio

% draw a sample of "sick" subjects
% with replacement, grab 20 subjects from a list of 24 subjects
% knock down the persistent component of the mel response by 1/3
% calculate and store mel/lms response ratio

% determine the significance of the group difference, and store that p
% value]

% after a whole bunch of simulations, we'll have a distribution of p values
% from this distribution, what percentage fall below our alpha threshold?
% we'll assign our alpha to be 0.01
% this percentage is our POWER (the ability to detect a reject the null
% hypothesis (p value less than alpha) when we know we should be -> and we
% always should be in these simulations because we're setting it such that
% there is a group difference
end