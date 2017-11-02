function [ TPUPParameters ] = fitTPUPToSubjectAverageResponses_bootstrapped(goodSubjects, TPUPParameters, dropboxAnalysisDir, varargin)

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
        
        for stimulus = 1:length(p.Results.stimulusLabels)
            
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
            
            
            for trial = 1:numberTrials
                packetCellArray(trial,:) = allTrials(:,trial)';
            end
            
            % sometimes trials will be included even if all values are
            % NaNs. This happens because if the normalization window is
            % entirely NaNs, the entire response becomes NaNs when
            % attempting to divide each value by the baseline size
            packetCellArray = packetCellArray(all(~isnan(packetCellArray),2),:);
            
            % now to do the bootstrapping.
            nBootstraps = 100;
            
            nTrials = size(packetCellArray,1);
            
            initialValues = [TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).delay(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).gammaTau(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).exponentialTau(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).transientAmplitude(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).sustainedAmplitude(ss), TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).persistentAmplitude(ss)];
            vlb = p.Results.lbTPUPbyStimulus(stimulus,:);
            vub = p.Results.ubTPUPbyStimulus(stimulus,:);
            
            for bb = 1:nBootstraps
                trialIdx = randsample(1:nTrials, nTrials, true);
                
                % make average ersponse out of these trials
                packetCellArray_bootstrapped = packetCellArray(trialIdx, :);
                averageResponse_bootstrapped = nanmean(packetCellArray_bootstrapped , 1);
                
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
                
                paramsFit.paramMainMatrix
                
                measures = {'delay', 'gammaTau', 'exponentialTau', 'transientAmplitude', 'sustainedAmplitude', 'persistentAmplitude'};
                for mm = 1:length(measures)
                    distribution.(measures{mm})(bb) = paramsFit.paramMainMatrix(mm);
                end
                distribution.totalResponseArea(bb) = paramsFit.paramMainMatrix(4) + paramsFit.paramMainMatrix(5) + paramsFit.paramMainMatrix(6)
            end % end bootstraps
            
            
            
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions