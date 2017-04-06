function [ amplitudesTransient, amplitudesTransientSEM, amplitudesSustained, amplitudesSustainedSEM, amplitudesPersistent, amplitudesPersistentSEM ] = fitTPUPToSubjectAverageResponses_byTrialBootstrap(goodSubjects, piprCombined, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir)

% The main output will be an [ss x 3] matrix, called amplitude, which contains the results
% from fitting the IAMP model to to average responses per subject. The
% first column will be the amplitude of LMS stimulation, the second column
% melanopsin stimulation, the third column pipr stimulation

stimulusOrder = {'LMS' 'mel' 'blue' 'red'};

paramLockMatrix = [];
IAMPFitToData = [];


for session = 1:2;
    amplitudes{session} = [];
    amplitudeTransient{session} = [];
    amplitudeSustained{session} = [];
    amplitudePersistent{session} = [];
    amplitudeTransientSEM{session} = [];
    amplitudeSustainedSEM{session} = [];
    amplitudePersistentSEM{session} = [];
    amplitudesSTD{session} = [];
    amplitudesSEM{session} = [];
    amplitudes_nonBootstrapped{session} = [];
    amplitudesSTD_nonBootstrapped{session} = [];
    numberOfTrials{session} = [];
    for subjects = 1:size(goodSubjects{session}{1},1)
        for stimuliTypes = 1:length(stimulusOrder)
            amplitudesTransient_byTrial{session}{subjects}{stimuliTypes} = [];
            amplitudesSustained_byTrial{session}{subjects}{stimuliTypes} = [];
            amplitudesPersistent_byTrial{session}{subjects}{stimuliTypes} = [];
            
        end
    end
    
end

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','none');

% Create the kernel for each stimulation type. For the IAMP model, the
% kernel will be the average group response for each stimulation, scaled to
% 1
for session = 1:2;
    for timepoints = 1:length(averageLMSCombined{session});
        LMSKernel(1,timepoints) = nanmean(averageLMSCombined{1}(:,timepoints));
        MelKernel(1,timepoints) = nanmean(averageMelCombined{1}(:,timepoints));
        PIPRKernel(1,timepoints) = nanmean(piprCombined{1}(:,timepoints));
        BlueKernel(1,timepoints) = nanmean(averageBlueCombined{1}(:,timepoints));
        RedKernel(1,timepoints) = nanmean(averageRedCombined{1}(:,timepoints));
    end
    LMSKernel = LMSKernel/abs(min(LMSKernel));
    MelKernel = MelKernel/abs(min(MelKernel));
    PIPRKernel = PIPRKernel/abs(min(PIPRKernel));
    BlueKernel = BlueKernel/abs(min(BlueKernel));
    RedKernel = RedKernel/abs(min(RedKernel));
    
    % create the timebase: events are 14 s long, and we're sampling every 20
    % ms
    timebase = (0:20:13998);
    
    % create stimulus profile -> has to be a blip with this
    % configuration of IAMP (it convolves the stimulus profile
    % with the kernel)
    stimulus.values = zeros(1,length(averageLMSCombined{session}));  % blip to be convolved with kernel; fixed per subject per contrast
    stimulus.values(1,1) = 1;
    stimulus.timebase = timebase;
    thePacket.stimulus = stimulus;
    
    
    %% Temporal domain of the stimulus
    deltaT = 20; % in msecs
    totalTime = 14000; % in msecs
    stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
    nTimeSamples = size(stimulusStruct.timebase,2);
    
    %% Specify the stimulus struct.
    % We create here a step function of neural activity, with half-cosine ramps
    %  on and off
    stepOnset=1000; % msecs
    stepDuration=3000; % msecs
    rampDuration=500; % msecs
    
    % the square wave step
    stimulusStruct.values=zeros(1,nTimeSamples);
    stimulusStruct.values(round(stepOnset/deltaT): ...
        round(stepOnset/deltaT)+round(stepDuration/deltaT)-1)=1;
    % half cosine ramp on
    stimulusStruct.values(round(stepOnset/deltaT): ...
        round(stepOnset/deltaT)+round(rampDuration/deltaT)-1)= ...
        fliplr((cos(linspace(0,pi*2,round(rampDuration/deltaT))/2)+1)/2);
    % half cosine ramp off
    stimulusStruct.values(round(stepOnset/deltaT)+round(stepDuration/deltaT)-round(rampDuration/deltaT): ...
        round(stepOnset/deltaT)+round(stepDuration/deltaT)-1)= ...
        (cos(linspace(0,pi*2,round(rampDuration/deltaT))/2)+1)/2;
    thePacket.stimulus.values = stimulusStruct.values;
    
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
            thePacket.kernel = [];
            
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
                % do the actual fitting via TPUP
                
                [paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(packetCellArray{trial}, 'defaultParamsInfo', defaultParamsInfo,'paramLockMatrix',paramLockMatrix);
                amplitudesTransient_byTrial{session}{ss}{stimulation} = [amplitudesTransient_byTrial{session}{ss}{stimulation}, paramsFit.paramMainMatrix(4)];
                amplitudesSustained_byTrial{session}{ss}{stimulation} = [amplitudesSustained_byTrial{session}{ss}{stimulation}, paramsFit.paramMainMatrix(5)];
                amplitudesPersistent_byTrial{session}{ss}{stimulation} = [amplitudesPersistent_byTrial{session}{ss}{stimulation}, paramsFit.paramMainMatrix(6)];
                
                %stimulusAmplitudes(trial) = paramsFit.paramMainMatrix;
            end
            %amplitudes_nonBootstrapped{session}(ss,stimulation) = mean(stimulusAmplitudes(1:length(packetCellArray)));
            %amplitudesSTD_nonBootstrapped{session}(ss,stimulation) = nanstd(stimulusAmplitudes(1:length(packetCellArray)));
            %numberOfTrials{session}(ss,stimulation) = length(packetCellArray);
            %if stimulation == 3;
            %figure; plot(thePacket.response.values); hold on; plot(modelResponseStruct.values); paramsFit.paramMainMatrix
            % end
        end
    end
end % end loop over sessions

%% now to do the bootstrapping:
measures = {'lms' 'mel' 'blue' 'red' 'pipr' 'mel/lms' 'blue/red' 'lms+mel' 'blue+red'};
nBootstraps = 100;

for amplitudeTypes = 1:3;
    if amplitudeTypes == 1;
        amplitudes_byTrial = amplitudesTransient_byTrial;
    elseif amplitudeTypes == 2;
        amplitudes_byTrial = amplitudesSustained_byTrial;
        
    elseif amplitudeTypes == 3;
        amplitudes_byTrial = amplitudesPersistent_byTrial;
        
    end
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
                if amplitudeTypes == 1;
                    amplitudesTransient{session}(ss,mm) = nanmean(result);
                    amplitudesTransientSEM{session}(ss,mm) = nanstd(result);
                elseif amplitudeTypes == 2;
                    amplitudesSustained{session}(ss,mm) = nanmean(result);
                    amplitudesSustainedSEM{session}(ss,mm) = nanstd(result);
                elseif amplitudeTypes == 3;
                    amplitudesPersistent{session}(ss,mm) = nanmean(result);
                    amplitudesPersistentSEM{session}(ss,mm) = nanstd(result);
                end
            end
        end
    end
end


%% do some plotting to summarize the results

for amplitudeTypes = 1:3;
    if amplitudeTypes == 1;
        amplitudes = amplitudesTransient;
        amplitudesSEM = amplitudesTransientSEM;
        name = 'transient';
    elseif amplitudeTypes == 2;
        amplitudes = amplitudesSustained;
        amplitudesSEM = amplitudesSustainedSEM;
        name = 'sustained';
    elseif amplitudeTypes == 3;
        amplitudes = amplitudesPersistent;
        amplitudesSEM = amplitudesPersistentSEM;
        name = 'persistent';
    end
    for session = 1:2
        
        %plot correlation of LMS and Mel
        plotFig = figure;
        hold on
        x = amplitudes{session}(:,1);
        y = amplitudes{session}(:,2);
        combined = [x; y];
        maxValue = max(combined);
        minValue = min(combined);
        errorbar(amplitudes{session}(:,1), amplitudes{session}(:,2), amplitudesSEM{session}(:,2), 'bo')
        herrorbar(amplitudes{session}(:,1), amplitudes{session}(:,2), amplitudesSEM{session}(:,1), 'bo')
        plot(-100:100,-100:100,'-')
        
        xlabel('LMS Amplitude (%)')
        ylabel('Mel Amplitude (%)')
        r = corr2(amplitudes{session}(:,1), amplitudes{session}(:,2));
        legend(['r = ', num2str(r)])
        hold on
        xnan = isnan(x);
        
        xnanlist = [];
        hits = 0;
        for xx = 1:length(x);
            if xnan(xx) == 1;
                hits = hits+1;
                x(xx-(hits-1)) = [];
                y(xx-(hits-1)) = [];
                
            end
        end
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 3)
        xlim([minValue maxValue]);
        ylim([minValue maxValue]);
        axis square
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [name, '_correlateLMSxMel.png']), 'png');
        close(plotFig);
        
        prettyScatterplots(amplitudes{session}(:,1), amplitudes{session}(:,2), amplitudesSEM{session}(:,1), amplitudesSEM{session}(:,2), 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'LMS Amplitude (%)', 'yLabel', 'Melanopsin Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, ['correlateLMSxMel_pretty.png']), 'saveType', 'png')
        
        
        % plot correlation of Mel and PIPR
        plotFig = figure;
        hold on
        x = amplitudes{session}(:,5);
        y = amplitudes{session}(:,2);
        combined = [x; y];
        maxValue = max(combined);
        minValue = min(combined);
        errorbar(amplitudes{session}(:,5), amplitudes{session}(:,2), amplitudesSEM{session}(:,2), 'bo')
        herrorbar(amplitudes{session}(:,5), amplitudes{session}(:,2), amplitudesSEM{session}(:,5), 'bo')
        plot(-100:100,-100:100,'-')
        
        xlabel('PIPR Amplitude (%)')
        ylabel('Mel Amplitude (%)')
        r = corr2(amplitudes{session}(:,5), amplitudes{session}(:,2));
        legend(['r = ', num2str(r)])
        hold on
        xnan = isnan(x);
        
        xnanlist = [];
        hits = 0;
        for xx = 1:length(x);
            if xnan(xx) == 1;
                hits = hits+1;
                x(xx-(hits-1)) = [];
                y(xx-(hits-1)) = [];
                
            end
        end
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 3)
        xlim([minValue maxValue]);
        ylim([minValue maxValue]);
        axis square
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [name, '_correlateMelxPIPR.png']), 'png');
        close(plotFig);
        
        % plot correlation of PIPR and LMS
        plotFig = figure;
        hold on
        y = amplitudes{session}(:,1);
        x = amplitudes{session}(:,5);
        combined = [x; y];
        maxValue = max(combined);
        minValue = min(combined);
        errorbar(amplitudes{session}(:,5), amplitudes{session}(:,1), amplitudesSEM{session}(:,1), 'bo')
        herrorbar(amplitudes{session}(:,5), amplitudes{session}(:,1), amplitudesSEM{session}(:,5), 'bo')
        plot(-100:100,-100:100,'-')
        
        ylabel('LMS Amplitude (%)')
        xlabel('PIPR Amplitude (%)')
        r = corr2(amplitudes{session}(:,5), amplitudes{session}(:,1));
        legend(['r = ', num2str(r)])
        hold on
        xnan = isnan(x);
        
        xnanlist = [];
        hits = 0;
        for xx = 1:length(x);
            if xnan(xx) == 1;
                hits = hits+1;
                x(xx-(hits-1)) = [];
                y(xx-(hits-1)) = [];
                
            end
        end
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 3)
        xlim([minValue maxValue]);
        ylim([minValue maxValue]);
        axis square
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [name, '_correlateLMSxPIPR.png']), 'png');
        close(plotFig);
        
        % plot correlation of blue and red
        plotFig = figure;
        hold on
        x = amplitudes{session}(:,3);
        y = amplitudes{session}(:,4);
        combined = [x; y];
        maxValue = max(combined);
        minValue = min(combined);
        errorbar(amplitudes{session}(:,3),amplitudes{session}(:,4), amplitudesSEM{session}(:,4), 'bo')
        herrorbar(amplitudes{session}(:,3),amplitudes{session}(:,4), amplitudesSEM{session}(:,3), 'bo')
        plot(-100:100,-100:100,'-')
        
        xlabel('Blue Amplitude (%)')
        ylabel('Red Amplitude (%)')
        r = corr2(amplitudes{session}(:,3), amplitudes{session}(:,4));
        legend(['r = ', num2str(r)])
        hold on
        xnan = isnan(x);
        
        xnanlist = [];
        hits = 0;
        for xx = 1:length(x);
            if xnan(xx) == 1;
                hits = hits+1;
                x(xx-(hits-1)) = [];
                y(xx-(hits-1)) = [];
                
            end
        end
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 3)
        xlim([minValue maxValue]);
        ylim([minValue maxValue]);
        axis square
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [name, '_correlateBluexRed.png']), 'png');
        close(plotFig);
        
        prettyScatterplots(amplitudes{session}(:,3), amplitudes{session}(:,4), amplitudesSEM{session}(:,3), amplitudesSEM{session}(:,4), 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'Blue Amplitude (%)', 'yLabel', 'Red Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, ['correlateBluexRed_pretty.png']), 'saveType', 'png')
        
        
        % plot correlation of [blue + red]/2 and [LMS + mel]/2
        plotFig = figure;
        hold on
        x = amplitudes{session}(:,9);
        y = amplitudes{session}(:,8);
        combined = [x; y];
        maxValue = max(combined);
        minValue = min(combined);
        errorbar(amplitudes{session}(:,9),amplitudes{session}(:,8), amplitudesSEM{session}(:,8), 'bo')
        herrorbar(amplitudes{session}(:,9), amplitudes{session}(:,8), amplitudesSEM{session}(:,9), 'bo')
        plot(-100:100,-100:100,'-')
        
        xlabel('(Blue+Red)/2 Amplitude (%)')
        ylabel('(LMS+Mel)/2 Amplitude (%)')
        r = corr2(amplitudes{session}(:,9),amplitudes{session}(:,8));
        legend(['r = ', num2str(r)])
        hold on
        xnan = isnan(x);
        
        xnanlist = [];
        hits = 0;
        for xx = 1:length(x);
            if xnan(xx) == 1;
                hits = hits+1;
                x(xx-(hits-1)) = [];
                y(xx-(hits-1)) = [];
                
            end
        end
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 3)
        xlim([minValue maxValue]);
        ylim([minValue maxValue]);
        
        axis square
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [name, '_correlateBlueRedxMelLMS.png']), 'png');
        close(plotFig);
        
        prettyScatterplots(amplitudes{session}(:,9), amplitudes{session}(:,8), amplitudesSEM{session}(:,9), amplitudesSEM{session}(:,8), 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', '(Blue+Red)/2 Amplitude (%)', 'yLabel', '(Mel+LMS)/2 Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, ['correlateBlueRedxMelLMS_pretty.png']), 'saveType', 'png')
        
        % plot correlation of [blue/red] and [mel/lms]
        x=[];
        y=[];
        plotFig = figure;
        hold on
        %for tt = 1:length(amplitudes{session}(:,4))
        %   x(tt) = amplitudes{session}(tt,3)/amplitudes{session}(tt,4);
        %   y(tt) = (amplitudes{session}(tt,2)/amplitudes{session}(tt,1));
        %end
        x = amplitudes{session}(:,7);
        y = amplitudes{session}(:,6);
        combined = [x; y];
        maxValue = max(combined);
        minValue = min(combined);
        %covarianceMelLMS = cov(amplitudes{session}(:,1), amplitudes{session}(:,2));
        %covarianceMelLMS = covarianceMelLMS(1,2);
        %semMelOverLMS = sqrt(1./((amplitudes{session}(:,1).^2)).*(amplitudesSTD{session}(:,2).^2)+(amplitudes{session}(:,2).^2)./(amplitudes{session}(:,1).^4).*(amplitudesSTD{session}(:,1).^2)-2*amplitudes{session}(:,2)./(amplitudes{session}(:,1).^3)*covarianceMelLMS)./sqrt((numberOfTrials{session}(:,1)+numberOfTrials{session}(:,2))/2);
        %covarianceBlueRed = cov(amplitudes{session}(:,3), amplitudes{session}(:,4));
        %covarianceBlueRed = covarianceBlueRed(1,2);
        %semBlueOverRed = sqrt(1./((amplitudes{session}(:,4).^2)).*(amplitudesSTD{session}(:,3).^2)+(amplitudes{session}(:,3).^2)./(amplitudes{session}(:,4).^4).*(amplitudesSTD{session}(:,4).^2)-2*amplitudes{session}(:,3)./(amplitudes{session}(:,4).^3)*covarianceBlueRed)./sqrt((numberOfTrials{session}(:,3)+numberOfTrials{session}(:,4))/2);
        %covarianceBlueRed = cov(amplitudes{session}(:,3), amplitudes{session}(:,4));
        errorbar(amplitudes{session}(:,7), amplitudes{session}(:,6), amplitudesSEM{session}(:,6), 'bo')
        herrorbar(amplitudes{session}(:,7), amplitudes{session}(:,6), amplitudesSEM{session}(:,7), 'bo')
        plot(-100:100,-100:100,'-')
        xlim([minValue maxValue])
        ylim([minValue maxValue])
        
        xlabel('Blue/Red Amplitude')
        ylabel('Mel/LMS Amplitude')
        r = corr2(x, y);
        legend(['r = ', num2str(r)])
        hold on
        xnan = isnan(x);
        
        xnanlist = [];
        hits = 0;
        for xx = 1:length(x);
            if xnan(xx) == 1;
                hits = hits+1;
                x(xx-(hits-1)) = [];
                y(xx-(hits-1)) = [];
                
            end
        end
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 3)
        
        outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [name, '_correlateBlueToRedxMelToLMS.png']), 'png');
        close(plotFig);
        
    end % end loop over sessions
end

measures = {'lms' 'mel' 'blue' 'red'};
for mm = 1:length(measures)
    for session = 1:2
        
        prettyScatterplots(amplitudesPersistent{session}(:,mm), amplitudesTransient{session}(:,mm), amplitudesPersistentSEM{session}(:,mm), amplitudesTransientSEM{session}(:,mm), 'xLabel', 'Persistent Amplitude', 'yLabel', 'Transient Amplitude', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, [measures{mm}, '_persistentxTransient_pretty.png']), 'saveType', 'png')
        
        
        prettyScatterplots(amplitudesPersistent{session}(:,mm), amplitudesSustained{session}(:,mm), amplitudesPersistentSEM{session}(:,mm), amplitudesSustainedSEM{session}(:,mm), 'xLabel', 'Persistent Amplitude', 'yLabel', 'Sustained Amplitude', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, [measures{mm}, '_persistentxSustained_pretty.png']), 'saveType', 'png')

        prettyScatterplots(amplitudesSustained{session}(:,mm), amplitudesTransient{session}(:,mm), amplitudesSustainedSEM{session}(:,mm), amplitudesTransientSEM{session}(:,mm), 'xLabel', 'Sustained Amplitude', 'yLabel', 'Transient Amplitude', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, [measures{mm}, '_sustainedxTransient_pretty.png']), 'saveType', 'png')
    end
end

end % end function