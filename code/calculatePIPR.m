function [ sustainedAmplitudes, pipr, netPipr ] = calculatePIPR(subjects, amplitudes, amplitudesSTD, numberOfTrials, dropboxAnalysisDir)

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
stimulusOnsetTime = 0;
stimulusOffsetTime = 3;
%sustainedOnsetTime = 10; % 10 s after stimulus offset
sustainedOnsetTime = 4.46 % when the response to melanopsin is scaled to the same size as the response to LMS stimulation, the melanopsin response crosses over at 4.46 s
sustainedOffsetTime = 14; % to the end of an individual trial
% we are sampling pupil diameter every 20 ms, so this time window will
% include the following indices
sustainedWindow = (sustainedOnsetTime/0.02):(sustainedOffsetTime/0.02);


%% First to calculate the sustained amplitudes
% For each subject for each trial of red and blue light, determine the
% average sustained amplitude. Then determine the average sustained
% amplitude for each subject across all red or all blue trials
for session = 1:2;
    sustainedAmplitudes{session} = [];
    pipr{session} = [];
    netPipr{session} = [];
end

for session = 1:2;
    for ss = 1:size(subjects{session},1);
        subject = subjects{session}(ss,:);
        numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
        
        % determine the date of a session
        dateList = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        dateList = dateList(~ismember({dateList.name},{'.','..', '.DS_Store'}));
        
        if numberSessions == 1;
            date = dateList(1).name;
        end
        if numberSessions == 2;
            if session == 1;
                date = dateList(2).name;
            elseif session == 2;
                date = dateList(1).name;
            end
        end
        blue = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
        red = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
        for stimuli = 1:2;
            if stimuli == 1;
                color = blue;
            elseif stimuli == 2;
                color = red;
            end
            for trial = 1:size(color,2);
                sustainedStimulusCombined(trial) = nanmean(color(sustainedWindow,trial));
            end
            sustainedAmplitudes{session}(ss,stimuli) = nanmean(sustainedStimulusCombined);
        end
    end
end

%% Now to calculate the actual PIPR values
for session = 1:2;
    for ss = 1:size(subjects{session},1);
        pipr{session}(ss) = 0 - sustainedAmplitudes{session}(ss,1)*100;
        netPipr{session}(ss) = ((0 - sustainedAmplitudes{session}(ss,1)) - (0 - sustainedAmplitudes{session}(ss,2)))*100;
    end
end
%% Plot these results to show how the different values of PIPR relate to each other
% Plot correlation of this PIPR with IAMP PIPR
for session = 1:2;
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/calculatePIPR', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    plotFig = figure;
    plot(pipr{session}, ((amplitudes{session}(:,3)*100)-(amplitudes{session}(:,4)*100)), 'o');
    xlabel('PIPR (Baseline - Sustained, %)')
    ylabel('PIPR (IAMP, %)')
    
    saveas(plotFig, fullfile(outDir, ['piprxIAMPPipr_', num2str(sustainedOnsetTime), '.png']), 'png');
    close(plotFig);
    
    
    % Plot correlation of PIPR and net PIPR
    plotFig = figure;
    plot(pipr{session}, netPipr{session}, 'o');
    xlabel('PIPR (Baseline - Sustained, %)')
    ylabel('Net PIPR (Blue PIPR - Red PIPR, %)')
    saveas(plotFig, fullfile(outDir, ['piprxNetPipr_', num2str(sustainedOnsetTime), '.png']), 'png');
    close(plotFig);
    
    % Plot correlation of net PIPR and IAMP PIPR
    plotFig = figure;
    plot(netPipr{session}, ((amplitudes{session}(:,3)*100)-(amplitudes{session}(:,4)*100)), 'o');
    xlabel('Net PIPR (Blue PIPR - Red PIPR, %)')
    ylabel('PIPR (IAMP, %)')
    saveas(plotFig, fullfile(outDir, ['netPiprxIAMPPipr_', num2str(sustainedOnsetTime), '.png']), 'png');
    close(plotFig);
    
    % Plot correlation of PIPR and Melanopsin-directed silent substitution
    plotFig = figure;
    plot(pipr{session}, amplitudes{session}(:,2)*100, 'o');
    xlabel('PIPR (Baseline - Sustained, %)')
    ylabel('Melanopsin Silent Substitution Amplitude (%)')
    saveas(plotFig, fullfile(outDir, ['piprxMel_', num2str(sustainedOnsetTime), '.png']), 'png');
    close(plotFig);
    
    % Plot correlation of Net PIPR and Melanopsin-directed silent substitution
    plotFig = figure;
    plot(netPipr{session}, amplitudes{session}(:,2)*100, 'o');
    xlabel('Net PIPR (Blue PIPR - Red PIPR, %)')
    ylabel('Melanopsin Silent Substitution Amplitude (%)')
    saveas(plotFig, fullfile(outDir, ['netPiprxMel_', num2str(sustainedOnsetTime), '.png']), 'png');
    close(plotFig);
end % end loop over sessions

end % end function
