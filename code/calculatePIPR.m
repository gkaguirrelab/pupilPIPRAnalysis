function [ pipr, netPipr ] = calculatePIPR(subjects, amplitudes, dropboxAnalysisDir, varargin)

% the purpose of this function is to calculate the PIPR according to a
% couple of different possible methods.

% The first basic methodology for computing the PIPR found here is to look
% at the sustained amplitude. Sustained refers to a period of time after
% light-offset while the pupil is still constricted relative to baseline.
% When the sustained window occurs can be specified in calling the
% function, either by picking a single instant in time or picking a window
% of time. For some references about certain sustained windows to chose:

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
% stimulus. 

% some reasonable default parameters
sustainedOnsetTime = 4.46; % when the response to melanopsin is scaled to the same size as the response to LMS stimulation, the melanopsin response crosses over at 4.46 s
sustainedOffsetTime = 14; % to the end of an individual trial

% we are sampling pupil diameter every 20 ms, so this time window will
% include the following indices
sustainedWindow = (sustainedOnsetTime/0.02):(sustainedOffsetTime/0.02);

% input parsing
p = inputParser; p.KeepUnmatched = true;

p.addParameter('computeMethod','window',@ischar);
p.addParameter('plot','no',@ischar);
p.addParameter('timeOn',sustainedOnsetTime,@isnumeric);
p.addParameter('timeOff',sustainedOffsetTime,@isnumeric);

p.parse(varargin{:});


%% first compute method: window
% For this calculation of the PIPR, we are determining the sustained
% amplitude for each subject, which refers to pupil diameter during a period of time after light
% offset. the pipr then is the sustained amplitude of blue minus the sustained amplitude of the red
% this approach more closely follows what is seen in the rest of the
% literature, although the exact timing of the windows varies (can
% generally either be an instaneous diameter at a certain moment, or the
% average diameter over a period of time)

if strcmp(p.Results.computeMethod, 'window')
    
    % First to calculate the sustained amplitudes
    
    % determine the sustained window
    sustainedOnsetTime = p.Results.timeOn; 
    sustainedOffsetTime = p.Results.timeOff; % to the end of an individual trial
    % we are sampling pupil diameter every 20 ms, so this time window will
    % include the following indices
    sustainedWindow = (sustainedOnsetTime/0.02):(sustainedOffsetTime/0.02);
    
    % For each subject for each trial of red and blue light, determine the
    % average sustained amplitude. Then determine the average sustained
    % amplitude for each subject across all red or all blue trials
    for session = 1:2;
        sustainedAmplitudes{session} = [];
        pipr{session} = [];
        netPipr{session} = [];
    end
    
    for session = 1:2;
        for ss = 1:size(subjects{session}{1},1);
            subject = subjects{session}{1}(ss,:);
            numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
            numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
            
            date = subjects{session}{2}(ss,:);
            
            blue = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
            red = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
            for stimuli = 1:2;
                if stimuli == 1;
                    color = blue;
                elseif stimuli == 2;
                    color = red;
                end
                sustainedStimulusCombined = [];
                for trial = 1:size(color,2);
                    sustainedStimulusCombined(trial) = nanmean(color(round(sustainedWindow),trial));
                end
                sustainedAmplitudes{session}(ss,stimuli) = nanmean(sustainedStimulusCombined);
            end
        end
    end
    
    % Now to calculate the actual PIPR values
    for session = 1:2;
        for ss = 1:size(subjects{session}{1},1);
            pipr{session}(ss) = 0 - sustainedAmplitudes{session}(ss,1)*100;
            netPipr{session}(ss) = ((0 - sustainedAmplitudes{session}(ss,1)) - (0 - sustainedAmplitudes{session}(ss,2)))*100;
        end
    end
end

%% Second compute method: total amplitude
% compute PIPR by determining amplitude based on the total time series. we
% get a group average fit to both blue and red stimulus. for each subject,
% determine the beta coefficient for the linear regression of this group
% average to each individual subject; this will be our amplitude component.
% determine the PIPR then by subtracting the blue amplitude from the red
% amplitude

if strcmp(p.Results.computeMethod, 'totalAmplitude')
    for session = 1:2 % loop over session
        for ss = 1:size(subjects{session}{1},1);
            netPipr{session}(ss) = amplitudes{session}(ss, 3) - amplitudes{session}(ss, 4);
        end
    end
end

% the pipr results variable doesn't make much sense in this context, it's
% just the red and blue amplitude results already found in the amplitude
% variable
if strcmp(p.Results.computeMethod, 'totalAmplitude')
    for session = 1:2 % loop over session
        for ss = 1:size(subjects{session}{1},1);
            pipr{session}(ss) = amplitudes{session}(ss, 3);
        end
    end
end

%% Plot these results to show how the different values of PIPR relate to each other
if strcmp(p.Results.plot, 'yes')
    subDir = 'pupilPIPRAnalysis/IAMP/calculatePIPR'
    
    % Plot correlation of this PIPR with IAMP PIPR
    for session = 1:2;
        outDir = fullfile(dropboxAnalysisDir,subDir, num2str(session));
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
end
%%

end % end function
