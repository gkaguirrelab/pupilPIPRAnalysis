function [ sustainedAmplitudes, pipr, netPipr ] = calculatePIPR(subjects, amplitudes, dropboxAnalysisDir)

% The purpose of this function is to calculate the PIPR a list of subjects
% by following the protocol laid out by Kankipati 2010
% They use the following definitions for the PIPR:
% PIPR  (mm) = Baseline Pupil Diameter  (mm) - Sustained Pupil Diameter  (mm) 
%       where baseline pupil diameter is the average pupil diameter for the
%       7 seconds prior to stimulus onset and sustained pupil diameter is
%       the average pupil diameter over a 30 second period beginning 10 s
%       after stimulus offset
% PIPR Change (%) = PIPR * 100 / Baseline Pupil Diameter 
% Net PIPR (mm) = Blue PIPR - Red PIPR 
% Net PIPR Change (%) = Blue PIPR Change (%) - Red PIPR Change (%)  

% In the paper, they state that PIPR and baseline pupil size show a very
% high correlation from day to day. However, they describe inter-individual 
% variation in the net PIPR change (%) might relate to inter-individual
% variation in melanopsin

% We are limited in our own study design in the extent to which we can
% replicate the specific results from the Kankipati paper specifically
% because our stimuli come too frequently; we cannot have a 30 second
% period beginning 10 s after stimulus offset to define our sustained
% amplitude because the pupil will already be responding to the next
% stimulus. We will also be thinking about the pupil in terms of percentage
% change from baseline, so we will specifically be calculating the PIPR
% change % and the net PIPR change %
% For our purposes, we will define sustained pupil size as pupil diameter
% averaged over a 1 s window (the longest we can achieve) starting
% from 10 seconds after stimulus offset
stimulusOnsetTime = 1;
stimulusOffsetTime = 3;
sustainedOnsetTime = 13; % 10 s after stimulus offset
sustainedOffsetTime = 14; % to the end of an individual trial
% we are sampling pupil diameter every 20 ms, so this time window will
% include the following indices
sustainedWindow = (sustainedOnsetTime/0.02):(sustainedOffsetTime/0.02);


%% First to calculate the sustained amplitudes
% For each subject for each trial of red and blue light, determine the
% average sustained amplitude. Then determine the average sustained
% amplitude for each subject across all red or all blue trials

for ss = 1:length(subjects);
    subject = subjects(ss,:);
    blue = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
    red = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
    for stimuli = 1:2;
        if stimuli == 1;
            color = blue;
        elseif stimuli == 2;
            color = red;
        end
        for trial = 1:size(color,2);
            sustainedStimulusCombined(trial) = nanmean(color(sustainedWindow,trial));
        end
        sustainedAmplitudes(ss,stimuli) = nanmean(sustainedStimulusCombined);
    end
end
        
%% Now to calculate the actual PIPR values
for ss = 1:length(subjects);
    pipr(ss) = sustainedAmplitudes(ss,1)*100;
    netPipr(ss) = (sustainedAmplitudes(ss,1) - sustainedAmplitudes(ss,2))*100;
end

%% Plot these results to show how the different values of PIPR relate to each other
% Plot correlation of this PIPR with IAMP PIPR
plotFig = figure;
plot(pipr, ((amplitudes(:,4)*100)-(amplitudes(:,5)*100)), 'o');
xlabel('PIPR (Baseline - Sustained, %)')
ylabel('PIPR (IAMP, %)')

% Plot correlation of PIPR and net PIPR
plotFig = figure;
plot(pipr, netPipr, 'o');
xlabel('PIPR (Baseline - Sustained, %)')
ylabel('Net PIPR (Blue PIPR - Red PIPR, %)')

% Plot correlation of net PIPR and IAMP PIPR
plotFig = figure;
plot(netPipr, ((amplitudes(:,4)*100)-(amplitudes(:,5)*100)), 'o');
xlabel('Net PIPR (Blue PIPR - Red PIPR, %)')
ylabel('PIPR (IAMP, %)')

% Plot correlation of PIPR and Melanopsin-directed silent substitution
plotFig = figure;
plot(pipr, amplitudes(:,2)*100, 'o');
xlabel('PIPR (Baseline - Sustained, %)')
ylabel('Melanopsin Silent Substitution Amplitude (%)')

% Plot correlation of Net PIPR and Melanopsin-directed silent substitution
plotFig = figure;
plot(netPipr, amplitudes(:,2)*100, 'o');
xlabel('Net PIPR (Blue PIPR - Red PIPR, %)')
ylabel('Melanopsin Silent Substitution Amplitude (%)')

    