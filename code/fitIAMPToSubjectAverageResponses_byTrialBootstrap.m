function [ amplitudes, amplitudesSEM ] = fitIAMPToSubjectAverageResponses_byTrialBootstrap(goodSubjects, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir)

% The main output will be an [ss x 3] matrix, called amplitude, which contains the results
% from fitting the IAMP model to to average responses per subject. The
% first column will be the amplitude of LMS stimulation, the second column
% melanopsin stimulation, the third column pipr stimulation

stimulusOrder = {'LMS' 'mel' 'blue' 'red'};

paramLockMatrix = [];
IAMPFitToData = [];

for session = 1:2;
    amplitudes{session} = [];
    amplitudesSTD{session} = [];
    amplitudesSEM{session} = [];
    amplitudes_nonBootstrapped{session} = [];
    amplitudesSTD_nonBootstrapped{session} = [];
    numberOfTrials{session} = [];
    for subjects = 1:size(goodSubjects{session}{1},1)
        for stimuliTypes = 1:length(stimulusOrder)
            amplitudes_byTrial{session}{subjects}{stimuliTypes} = [];
        end
    end
    
end

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeIAMP('verbosity','none');

% Create the kernel for each stimulation type. For the IAMP model, the
% kernel will be the average group response for each stimulation, scaled to
% 1
for session = 1:2;
    for timepoints = 1:length(averageLMSCombined{session});
        LMSKernel(1,timepoints) = nanmean(averageLMSCombined{1}(:,timepoints));
        MelKernel(1,timepoints) = nanmean(averageMelCombined{1}(:,timepoints));
        BlueKernel(1,timepoints) = nanmean(averageBlueCombined{1}(:,timepoints));
        RedKernel(1,timepoints) = nanmean(averageRedCombined{1}(:,timepoints));
    end
    LMSKernel = LMSKernel/abs(min(LMSKernel));
    MelKernel = MelKernel/abs(min(MelKernel));
    BlueKernel = BlueKernel/abs(min(BlueKernel));
    RedKernel = RedKernel/abs(min(RedKernel));
    
    % create the timebase: events are 14 s long, and we're sampling every 20
    % ms
    timebase = (1:length(averageLMSCombined{session}));
    
    % create stimulus profile -> has to be a blip with this
    % configuration of IAMP (it convolves the stimulus profile
    % with the kernel)
    stimulus.values = zeros(1,length(averageLMSCombined{session}));  % blip to be convolved with kernel; fixed per subject per contrast
    stimulus.values(1,1) = 1;
    stimulus.timebase = timebase;
    thePacket.stimulus = stimulus;
    
    for ss = 1:size(goodSubjects{session}{1},1); % loop over subjects
        
        
        subject = goodSubjects{session}{1}(ss,:);
        numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
        date = goodSubjects{session}{2}(ss,:);

        
        for stimulation = 1:length(stimulusOrder);
            if stimulation == 1; % LMS condition
                kernel.values = LMSKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseLMS', subject, date, [subject, '_PupilPulseData_MaxLMS_TimeSeries.csv']));
                
            elseif stimulation == 2; % mel condition
                kernel.values = MelKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseMel', subject, date, [subject, '_PupilPulseData_MaxMel_TimeSeries.csv']));
            elseif stimulation == 3; % blue condition
                kernel.values = BlueKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
            elseif stimulation == 4; % red condition
                kernel.values = RedKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
                
            end
            
            % finish kernel assembly
            kernel.timebase = timebase;
            thePacket.kernel = kernel;
            
            % create packet metaData
            thePacket.metaData = [];
            
            % determine number of trials
            numberTrials = size(allTrials,2);
            
            packetCellArray = [];
            for trial = 1:numberTrials
                packetCellArray{trial} = [];
            end
            for trial = 1:numberTrials
                packetCellArray{trial} = thePacket;
                if sum(isnan(allTrials(:,trial))) ~= 700;
                    packetCellArray{trial}.response.values = allTrials(:,trial)';
                    packetCellArray{trial}.response.timebase = timebase;
                else
                    packetCellArray{trial} = [];
                    
                end
            end
            
            packetCellArray = packetCellArray(~cellfun('isempty',packetCellArray));
            
            
            for trial = 1:length(packetCellArray)
                % do the actual fitting via IAMP
                
                [paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(packetCellArray{trial}, 'defaultParamsInfo', defaultParamsInfo,'paramLockMatrix',paramLockMatrix);
                amplitudes_byTrial{session}{ss}{stimulation} = [amplitudes_byTrial{session}{ss}{stimulation}, paramsFit.paramMainMatrix]; 
                stimulusAmplitudes(trial) = paramsFit.paramMainMatrix;
            end
            amplitudes_nonBootstrapped{session}(ss,stimulation) = mean(stimulusAmplitudes(1:length(packetCellArray)));
            amplitudesSTD_nonBootstrapped{session}(ss,stimulation) = nanstd(stimulusAmplitudes(1:length(packetCellArray)));
            numberOfTrials{session}(ss,stimulation) = length(packetCellArray);
            
        end
    end
end % end loop over sessions

%% now to do the bootstrapping:
measures = {'lms' 'mel' 'blue' 'red' 'pipr' 'mel/lms' 'blue/red' 'lms+mel' 'blue+red'};
nBootstraps = 1000000;

for session = 1:2
    for ss = 1:size(goodSubjects{session}{1},1)
        for mm = 1:length(measures)
            if mm < 5 % for the lms, mel, blue, and red conditions, the bootstrap approach will be the same
                result = [];
                for bb = 1:nBootstraps
                   
                   nTrials = length(amplitudes_byTrial{session}{ss}{mm}); 
                   trialIdx = randsample(1:nTrials, nTrials, true);
                   result = [result, nanmean(amplitudes_byTrial{session}{ss}{mm}(trialIdx))];
                end
                
            end
            if mm == 5; % this is the pipr condition, for which the calculation we want is the blue amplitude - the red amplitude
                result = [];
                for bb = 1:nBootstraps
                    nBlueTrials = length(amplitudes_byTrial{session}{ss}{3});
                    nRedTrials = length(amplitudes_byTrial{session}{ss}{4});
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(amplitudes_byTrial{session}{ss}{3}(blueTrialIdx)) - nanmean(amplitudes_byTrial{session}{ss}{4}(redTrialIdx)))];
                end
            end
            if mm == 6; % this is the mel/lms condition
                result = [];
                for bb = 1:nBootstraps
                    nMelTrials = length(amplitudes_byTrial{session}{ss}{2});
                    nLMSTrials = length(amplitudes_byTrial{session}{ss}{1});
                    melTrialIdx = randsample(1:nMelTrials, nMelTrials, true);
                    LMSTrialIdx = randsample(1:nLMSTrials, nLMSTrials, true);
                    result = [result, nanmean(amplitudes_byTrial{session}{ss}{2}(melTrialIdx))/nanmean(amplitudes_byTrial{session}{ss}{1}(LMSTrialIdx))];

                end
            end
            if mm == 7; % this is the blue/red condition
                result = [];
                for bb = 1:nBootstraps
                    nBlueTrials = length(amplitudes_byTrial{session}{ss}{3});
                    nRedTrials = length(amplitudes_byTrial{session}{ss}{4});
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(amplitudes_byTrial{session}{ss}{3}(blueTrialIdx))/nanmean(amplitudes_byTrial{session}{ss}{4}(redTrialIdx)))];
                end
            end
            if mm == 8; % this is the (LMS+mel)/2 condition
                result = [];
                for bb = 1:nBootstraps
                    nMelTrials = length(amplitudes_byTrial{session}{ss}{2});
                    nLMSTrials = length(amplitudes_byTrial{session}{ss}{1});
                    melTrialIdx = randsample(1:nMelTrials, nMelTrials, true);
                    LMSTrialIdx = randsample(1:nLMSTrials, nLMSTrials, true);
                    result = [result, (nanmean(amplitudes_byTrial{session}{ss}{2}(melTrialIdx))+nanmean(amplitudes_byTrial{session}{ss}{1}(LMSTrialIdx)))/2];
                end
            end
            if mm == 9; % this is the (blue+red)/2 condition
                result = [];
                for bb = 1:nBootstraps
                    nBlueTrials = length(amplitudes_byTrial{session}{ss}{3});
                    nRedTrials = length(amplitudes_byTrial{session}{ss}{4});
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(amplitudes_byTrial{session}{ss}{3}(blueTrialIdx))+nanmean(amplitudes_byTrial{session}{ss}{4}(redTrialIdx)))/2];
                end
            end
            amplitudes{session}(ss,mm) = nanmean(result);
            amplitudesSEM{session}(ss,mm) = nanstd(result);
        end
    end
end

%% plot show of fits

subDir = 'pupilPIPRAnalysis/IAMP/modelFits';
stimulusOrder = {'LMS' 'mel' 'blue' 'red'};


for session = 1:2
    for ss = 1:size(goodSubjects{session}{1},1)
        for mm = 1:length(stimulusOrder)
            if mm == 1 % LMS
                response = averageLMSCombined;
                kernel = LMSKernel;
                subFolder = 'LMS';
            elseif mm == 2 % mel
                response = averageMelCombined;
                kernel = MelKernel;
                subFolder = 'mel';
            elseif mm == 3 % blue
                response = averageBlueCombined;
                kernel = BlueKernel;
                subFolder = 'PIPR';
            elseif mm == 4
                response = averageRedCombined;
                kernel = RedKernel;
                subFolder = 'PIPR';
            end
        
   
            plotFig = figure;
            plot(timebase*0.02, response{session}(ss,:))
            hold on
            plot(timebase*0.02, kernel*amplitudes{session}(ss,mm))
            legend('Averaged Data', 'Model Fit')
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            
            % determine goodness of fit
            mdl = fitlm(response{session}(ss,:), kernel*amplitudes{session}(ss,mm));
            rSquared = mdl.Rsquared.Ordinary;
            
            % print some summary info to the plot
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.70*xrange;
            ypos = ylims(1)+0.20*yrange;
            
            string = (sprintf(['Amplitude: ', num2str(amplitudes{session}(ss,mm)), '\nAmplitude SEM: ',  num2str(amplitudesSEM{session}(ss,mm)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            
            outDir = fullfile(dropboxAnalysisDir,subDir, subFolder, num2str(session));
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            saveas(plotFig, fullfile(outDir, [goodSubjects{session}{1}(ss,:),'.png']), 'png');
            close(plotFig);
        end
    end
end
        
    
end % end function