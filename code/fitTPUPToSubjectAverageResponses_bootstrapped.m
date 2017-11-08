function [ TPUPParameters_bootstrapped ] = fitTPUPToSubjectAverageResponses_bootstrapped(goodSubjects, TPUPParameters, dropboxAnalysisDir, varargin)

%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;
p.addRequired('goodSubjects',@iscell);
p.addRequired('TPUPParameters',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);

% Optional display and I/O params
p.addParameter('verbose',true,@islogical);
p.addParameter('makePlots',true,@islogical);

% Optional analysis parameters
p.addParameter('stimulusLabels',{'LMS' 'Mel' 'Blue' 'Red'},@iscell);

% order of parameters is: delay, gamma tau, exponential tau, transient
% amplitude, sustained amplitude, and persistent amplitude.
% Each row corresponds to the bounds to use for each stimulus type, in the
% same order specified in 'stimulusLabels' above
p.addParameter('lbTPUPbyStimulus',[-500, 150, 1, -400, -400, -400; ... % LMS
    -500, 150, 1, -400, -400, -400; ... % Mel
    -500, 150, 1, -400, -400, -400; ... % Blue
    -500, 150, 1, -400, -400, -400],@isnumeric); % Red
p.addParameter('ubTPUPbyStimulus',[0, 400, 20, 0, 0, 0; ... % LMS
    0, 400, 20, 0, 0, 0; ... % Mel
    0, 750, 20, 0, 0, 0; ... % Blue
    0, 750, 20, 0, 0, 0],@isnumeric); % Red


p.addParameter('initialTemporalParameters',[-200, 350, 5],@isnumeric);    % delay, gamma tau, exponential tau
p.addParameter('stimulusTimebase',0:20:13980,@isnumeric); % gives a 700 index long vector, corresponding to a 14 second trial sampled each 20 milliseconds
p.addParameter('stimulusStepOnset',1000,@isnumeric); % in ms
p.addParameter('stimulusStepOffset',4000,@isnumeric); % in ms
p.addParameter('stimulusRampDuration',500,@isnumeric); % in ms
p.addParameter('initialValuesToSample',[-100, 0] ,@isnumeric);
p.addParameter('nInstances', 1 ,@isnumeric);

%% Parse and check the parameters
p.parse(goodSubjects, TPUPParameters, dropboxAnalysisDir, varargin{:});

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = p.Results.nInstances;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

% build up common parts of the packet
% make the stimulus profile
[stimulusStruct] =  makeStepPulseStimulusStruct(p.Results.stimulusTimebase, ...
    p.Results.stimulusStepOnset, ...
    p.Results.stimulusStepOffset, ...
    'rampDuration', p.Results.stimulusRampDuration);
thePacket.stimulus = stimulusStruct; % add stimulusStruct to the packet

% create the timebase for the response subfield, which is the same as that
% used for the stimulus timebase
thePacket.response.timebase = p.Results.stimulusTimebase;
% TPUP model requires no kernel
thePacket.kernel = [];
% TPUP model also requires no metaData
thePacket.metaData = [];

% a way to link the stimulus described in the stimuli vector above, with
% where that data lives (the blue and red are PIPR stimuli, and are located
% within the same folder.
stimuliType = {'LMS', 'Mel', 'PIPR', 'PIPR'};

for session = 1:length(goodSubjects)
    if session == 1 || session == 2
        subdir = '';
    elseif session == 3
        subdir = 'Legacy';
    end
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        fprintf(['Fitting subject %d, session %d. Started at ' char(datetime('now')), '\n'], ss, session)
        
        for stimulus = 1:length(p.Results.stimulusLabels)
            % create empty structure for accumulator
            accumulator.(p.Results.stimulusLabels{stimulus}) = struct('delay', {}, 'gammaTau', {}, 'exponentialTau', {}, 'transientAmplitude', {}, 'sustainedAmplitude', {}, 'persistentAmplitude', {}, 'totalResponseArea', {}, 'percentPersistent', {});
            
            
            % determine where the raw data for each trial lives. this
            % depends on the stimulus
            csvFileName = dir(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, [subject, '*', p.Results.stimulusLabels{stimulus}, '_TimeSeries.csv']));
            csvFileName = csvFileName.name;
            % load the raw data
            allTrials = importdata(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, csvFileName));
            % determine number of trials
            numberTrials = size(allTrials,2);
            
            % make a matrix to collect data from all trials for a given
            % stimulus condition for a given subject. each row in the
            % matrix will be the response from a separate trial
            
            trialsMatrix = [];
            for trial = 1:numberTrials
                trialsMatrix(trial,:) = allTrials(:,trial)';
            end
            
            % sometimes trials will be included even if all values are
            % NaNs. This happens because if the normalization window is
            % entirely NaNs, the entire response becomes NaNs when
            % attempting to divide each value by the baseline size
            trialsMatrix = trialsMatrix(all(~isnan(trialsMatrix),2),:);
            
            % now to do the bootstrapping.
            nBootstraps = 100;
            
            nTrials = size(trialsMatrix,1);
            
            initialValues = [TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).delay(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).gammaTau(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).exponentialTau(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).transientAmplitude(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).sustainedAmplitude(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).persistentAmplitude(ss)];
            vlb = p.Results.lbTPUPbyStimulus(stimulus,:);
            vub = p.Results.ubTPUPbyStimulus(stimulus,:);
            
            
            for bb = 1:nBootstraps
                trialIdx = randsample(1:nTrials, nTrials, true);
                
                % make average ersponse out of these trials
                trialsMatrix_bootstrapped = trialsMatrix(trialIdx, :);
                averageResponse_bootstrapped = nanmean(trialsMatrix_bootstrapped , 1);
                
                % stick the new bootstrapped average into the packet
                thePacket.response.values = averageResponse_bootstrapped*100;
                
                % do the fit
                [paramsFit,fVal,modelResponseStruct] = ...
                    temporalFit.fitResponse(thePacket, ...
                    'defaultParamsInfo', defaultParamsInfo, ...
                    'vlb', vlb, ...
                    'vub',vub,...
                    'initialValues',initialValues,...
                    'fminconAlgorithm','sqp'...
                    );
                
                components = {'delay', 'gammaTau', 'exponentialTau', 'transientAmplitude', 'sustainedAmplitude', 'persistentAmplitude', 'totalResponseArea', 'percentPersistent'};
                
                % add total response area as a 7th parameter
                paramsFit.paramMainMatrix(7) = paramsFit.paramMainMatrix(4) + paramsFit.paramMainMatrix(5) + paramsFit.paramMainMatrix(6);
                
                % add percent persistent as an 8th parameter
                paramsFit.paramMainMatrix(8) = paramsFit.paramMainMatrix(6)/(paramsFit.paramMainMatrix(4) + paramsFit.paramMainMatrix(5) + paramsFit.paramMainMatrix(6));
                
                
                fitParams = cell2struct(num2cell(paramsFit.paramMainMatrix),components,2);
                accumulator.(p.Results.stimulusLabels{stimulus}) = [accumulator.(p.Results.stimulusLabels{stimulus}), fitParams];
            end % end bootstraps
            
            % extract information from bootstrap accumulator
            measures = fieldnames(accumulator.(p.Results.stimulusLabels{stimulus}));
            for mm = 1:length(measures)
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).(measures{mm})(ss) = mean([accumulator.(p.Results.stimulusLabels{stimulus})(:).(measures{mm})]);
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_SEM'])(ss) = std([accumulator.(p.Results.stimulusLabels{stimulus})(:).(measures{mm})]);;
                sorted = sort([accumulator.(p.Results.stimulusLabels{stimulus})(:).(measures{mm})]);
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_90'])(ss) = sorted(round(0.90*nBootstraps));
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_10'])(ss) = sorted(round(0.10*nBootstraps));
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_975'])(ss) = sorted(round(0.975*nBootstraps));
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_025'])(ss) = sorted(round(0.025*nBootstraps));
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_667'])(ss) = sorted(round(2/3*nBootstraps));
                TPUPParameters_bootstrapped{session}.(p.Results.stimulusLabels{stimulus}).([measures{mm}, '_333'])(ss) = sorted(round(1/3*nBootstraps));
            end
            
         
            
        end % end loop over stimuli
        
        % now determine the mel to lms response ratio
        nSimulations = 1000;
        for st = 1:nSimulations
            randomDraw = randsample(nBootstraps, 1);
            melResponse = accumulator.Mel(randomDraw).totalResponseArea;
            randomDraw = randsample(nBootstraps, 1);
            lmsResponse = accumulator.LMS(randomDraw).totalResponseArea;
            
            melToLMSAccumulator(st) = melResponse/lmsResponse;
        end
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea(ss) = mean(melToLMSAccumulator);
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_SEM(ss) = std(melToLMSAccumulator);
        
        sortedMeltoLMS = sort(melToLMSAccumulator);
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_90(ss) = sortedMeltoLMS(round(0.90*nSimulations));
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_10(ss) = sortedMeltoLMS(round(0.10*nSimulations));
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_975(ss) = sortedMeltoLMS(round(0.975*nSimulations));
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_025(ss) = sortedMeltoLMS(round(0.025*nSimulations));
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_667(ss) = sortedMeltoLMS(round(2/3*nSimulations));
        TPUPParameters_bootstrapped{session}.MeltoLMS.totalResponseArea_333(ss) = sortedMeltoLMS(round(1/3*nSimulations));
    end % end loop over subjects
end % end loop over sessions