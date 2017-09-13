function [ amplitudesPerSubject ] = fitIAMPToSubjectTrialResponses(goodSubjects, averageResponsePerSubject, groupAverageResponse, dropboxAnalysisDir)


% set up some basics
stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
stimuliType = {'LMS', 'Mel', 'PIPR', 'PIPR'}; % this will serve as a convenient way to link red and blue stimuli under the PIPR umbrella

defaultParamsInfo.nInstances = 1;

temporalFit = tfeIAMP('verbosity', 'none');

timebase = 0:20:13980;

% throw in parts of the packet that will be shared across all subjects.
% this includes the stimulus profile and the (lack of) metaData
% create a stimulus profile. for IAMP, this is a delta function
stimulus.values = zeros(1,length(timebase));
stimulus.values(1) = 1;
stimulus.timebase = timebase;
thePacket.stimulus = stimulus;
thePacket.metaData = [];

for session = 1:length(goodSubjects)
    if session == 1 || session == 2
        subdir = '';
    elseif session == 3
        subdir = 'Legacy';
    end
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        
        for stimulus = 1:length(stimuli)
        
        % our kernel will be the group average repsonse from the first
        % session
            thePacket.kernel.values = groupAverageResponse{1}.(stimuli{stimulus})/abs(min(groupAverageResponse{1}.(stimuli{stimulus})));
            thePacket.kernel.timebase = timebase;
            
            % determine where the raw data for each trial lives. this
            % depends on the stimulus
            csvFileName = dir(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, [subject, '*', stimuli{stimulus}, '_TimeSeries.csv']));
            csvFileName = csvFileName.name;
            % load the raw data
            allTrials = importdata(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, csvFileName));
            % determine number of trials
            numberTrials = size(allTrials,2);
            
            packetCellArray = [];
            
            %discard a trial if it is all NaNs, discard it
            for trial = 1:numberTrials
                packetCellArray{trial} = [];
            end
            for trial = 1:numberTrials
                packetCellArray{trial} = thePacket;
                if sum(isnan(allTrials(:,trial))) ~= 700
                    packetCellArray{trial}.response.values = allTrials(:,trial)';
                    packetCellArray{trial}.response.timebase = timebase;
                else
                    packetCellArray{trial} = [];
                    
                end
            end
            
            packetCellArray = packetCellArray(~cellfun('isempty',packetCellArray));
            
            % loop around trials to do the IAMP fit per trial
            for trial = 1:length(packetCellArray)
                
                % do the actual fitting via IAMP
                [paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(packetCellArray{trial}, 'defaultParamsInfo', defaultParamsInfo);
                amplitude = paramsFit.paramMainMatrix * 20; % the * 20 here is to get the amplitude in units that are sensible (despite having a kernel with a minimum value of -1, after applying the kernel with an amplitude parameter of 1, the minimum amplitude comes out to be -20. I think this has something to do with the 20 ms interval between timepoints in the timebase
                amplitudesPerTrial{session}.(stimuli{stimulus})(ss,trial) = amplitude;
                
                
            end % end loop over trials
                
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions

%% now do the bootstrapping

measures = {'LMS' 'Mel' 'Blue' 'Red' 'PIPR' 'MeltoLMS' 'BluetoRed' 'SilentSubstitionAverage' 'PIPRAverage'};
nBootstraps = 10000;

for session = 1:length(goodSubjects)
    for ss = 1:length(goodSubjects{session}.ID)
        for mm = 1:length(measures)
            
            result = [];
            
            if strcmp(measures{mm}, 'LMS') || strcmp(measures{mm}, 'Mel') || strcmp(measures{mm}, 'Blue') || strcmp(measures{mm}, 'Red')
                for bb = 1:nBootstraps
                    nTrials = length(amplitudesPerTrial{session}.(measures{mm})(ss,:));
                    trialIdx = randsample(1:nTrials, nTrials, true);
                    result = [result, nanmean(amplitudesPerTrial{session}.(measures{mm})(ss,trialIdx))];
                end
            elseif strcmp(measures{mm}, 'PIPR')
                for bb = 1:nBootstraps
                    nBlueTrials = length(amplitudesPerTrial{session}.Blue(ss,:));
                    nRedTrials = length(amplitudesPerTrial{session}.Red(ss,:));
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(amplitudesPerTrial{session}.Blue(ss,blueTrialIdx)) - nanmean(amplitudesPerTrial{session}.Red(ss,redTrialIdx)))];
                end
            elseif strcmp(measures{mm}, 'MeltoLMS')
                for bb = 1:nBootstraps
                    nMelTrials = length(amplitudesPerTrial{session}.Mel(ss,:));
                    nLMSTrials = length(amplitudesPerTrial{session}.LMS(ss,:));
                    melTrialIdx = randsample(1:nMelTrials, nMelTrials, true);
                    LMSTrialIdx = randsample(1:nLMSTrials, nLMSTrials, true);
                    result = [result, nanmean(amplitudesPerTrial{session}.Mel(ss,melTrialIdx))/nanmean(amplitudesPerTrial{session}.LMS(ss,LMSTrialIdx))];
                end
            elseif strcmp(measures{mm}, 'BluetoRed')
                for bb = 1:nBootstraps
                    nBlueTrials = length(amplitudesPerTrial{session}.Blue(ss,:));
                    nRedTrials = length(amplitudesPerTrial{session}.Red(ss,:));
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(amplitudesPerTrial{session}.Blue(ss,blueTrialIdx))/nanmean(amplitudesPerTrial{session}.Red(ss,redTrialIdx)))];
                end
            elseif strcmp(measures{mm}, 'SilentSubstitionAverage')
                for bb = 1:nBootstraps
                    nMelTrials = length(amplitudesPerTrial{session}.Mel(ss,:));
                    nLMSTrials = length(amplitudesPerTrial{session}.LMS(ss,:));
                    melTrialIdx = randsample(1:nMelTrials, nMelTrials, true);
                    LMSTrialIdx = randsample(1:nLMSTrials, nLMSTrials, true);
                    result = [result, (nanmean(amplitudesPerTrial{session}.Mel(ss,melTrialIdx))+nanmean(amplitudesPerTrial{session}.LMS(ss,LMSTrialIdx)))/2];
                end
            elseif strcmp(measures{mm}, 'PIPRAverage')
                for bb = 1:nBootstraps
                    nBlueTrials = length(amplitudesPerTrial{session}.Blue(ss,:));
                    nRedTrials = length(amplitudesPerTrial{session}.Red(ss,:));
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(amplitudesPerTrial{session}.Blue(ss,blueTrialIdx))+nanmean(amplitudesPerTrial{session}.Red(ss,redTrialIdx)))/2];
                end
            end
            amplitudesPerSubject{session}.(measures{mm})(ss) = nanmean(result);
            amplitudesPerSubject{session}.([measures{mm}, '_SEM'])(ss) = nanstd(result);
        end % end loop over measures
    end % end loop over subjects
end % end loop over sessions

%% Plot summary

subdir = 'pupilPIPRanalysis/IAMP/modelFits';

for session = 1:length(goodSubjects)
    for ss = 1:length(goodSubjects{session}.ID)
        for stimulus = 1:length(stimuli)
            plotFig = figure;
            plot(timebase, averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:))
            hold on
            plot(timebase, groupAverageResponse{session}.(stimuli{stimulus})/abs(min(groupAverageResponse{session}.(stimuli{stimulus})))*amplitudesPerSubject{session}.(stimuli{stimulus})(ss));
            legend('Averaged Data', 'Model Fit')
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            
            % determine goodness of fit
            mld = fitlm(averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:), groupAverageResponse{session}.(stimuli{stimulus})/abs(min(groupAverageResponse{session}.(stimuli{stimulus})))*amplitudesPerSubject{session}.(stimuli{stimulus})(ss));
            rSquared = mdl.Rsquared.Ordinary;
            
            % print some summary info to the plot
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.70*xrange;
            ypos = ylims(1)+0.20*yrange;
            
            string = (sprintf(['Amplitude: ', num2str(amplitudesPerSubject{session}.(stimuli{stimulus})(ss)), '\nAmplitude SEM: ',  num2str(amplitudesPerSubject{session}.([stimuli{stimulus}, '_SEM'])(ss)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            
            outDir = fullfile(dropboxAnalysisDir, subdir, stimuli{stimulus}, num2str(session));
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            saveas(plotFig, fullfile(outDir, [goodSubjects{session}.ID{ss},'.png']), 'png');
            close(plotFig);
        end
    end
end

end % end function