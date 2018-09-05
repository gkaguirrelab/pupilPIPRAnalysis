stimuli = {'Melanopsin', 'LMS'};

relevantTrialIndices = [];
relevantTrialIndices{1} = [1,7,13,19];
relevantTrialIndices{2} = [2,8,14,20];
relevantTrialIndices{3} = [3,9,15,21];
relevantTrialIndices{4} = [4,10,16,22];
relevantTrialIndices{5} = [5,11,17,23];
relevantTrialIndices{6} = [6,12,18,24];

% some TPUP stuff
% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

% set up boundaries for our fits
% although the boundaries are being coded here, the upper limit of the
% gamma tau will change depending on whether the stimulus is PIPR
% (blue/red) or silent substitution (mel/lms). This change will occur in
% the main loop.
vlb=[-500, 150, 1, -400, -400, -400]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, 400, 20, 0, 0, 0];
startingValues = [-100, 0];

% build up common parts of the packet
timebase = 0:20:13980; % in msec
stepOnset = 1000; % in msec
stepOffset = 4000; % in msec
[stimulusStruct] = makeStepPulseStimulusStruct(timebase, stepOnset, stepOffset, 'rampDuration', 500);
thePacket.stimulus = stimulusStruct; % add stimulusStruct to the packet
thePacket.response.timebase = timebase;
thePacket.kernel = [];
thePacket.metaData = [];

for session = 1:3
    for stimulus = 1:2
        totalResponseStruct{session}.(stimuli{stimulus}) = [];
    end
end

for session = 1:3
    for subject = 1:length(goodSubjects{session}.ID)
        for stimulus = 1:length(stimuli)
            trialData = [];
            
            if strcmp(stimuli{stimulus}, 'Melanopsin')
                csvPath = fullfile(dropboxAnalysisDir, 'PIPRSupplementalAnalyses', 'percentageChange_noTrialsRemovedPIPRMaxPulse_PulseMel', goodSubjects{session}.ID{subject}, goodSubjects{session}.date{subject}, [goodSubjects{session}.ID{subject}, '_PupilPulseData_MaxMel_TimeSeries.csv']);
            elseif strcmp(stimuli{stimulus}, 'LMS')
                csvPath = fullfile(dropboxAnalysisDir, 'PIPRSupplementalAnalyses', 'percentageChange_noTrialsRemovedPIPRMaxPulse_PulseLMS', goodSubjects{session}.ID{subject}, goodSubjects{session}.date{subject}, [goodSubjects{session}.ID{subject}, '_PupilPulseData_MaxLMS_TimeSeries.csv']);
            end
            
            if subject == 25 && session == 1 && stimulus ==2
                test=5;
            elseif subject == 5 && session == 3 && stimulus ==1
                test=5;
            elseif subject == 5 && session == 3 && stimulus ==2
                test=5;
            else
                
                
                trialData = cell2mat(textscan(fopen(csvPath),'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f'));
                
                for withinBlockIndex = 1:6
                    withinBlockAverage = nanmean(trialData(:,relevantTrialIndices{withinBlockIndex}),2)';
                    rSquaredPooled = []; % for each subject, for each condition, we want to look at the R2 values of each fit
                    for initialTransient = 1:2
                        for initialSustained = 1:2
                            for initialPersistent = 1:2
                                % build the packet
                                initialValues = [-200, 350, 5, startingValues(initialTransient), startingValues(initialSustained), startingValues(initialPersistent)];
                                
                                thePacket.response.values = withinBlockAverage*100;
                                [paramsFit,fVal,modelResponseStruct] = ...
                                    temporalFit.fitResponse(thePacket, ...
                                    'defaultParamsInfo', defaultParamsInfo, ...
                                    'vlb', vlb, 'vub',vub,...
                                    'initialValues',initialValues,...
                                    'fminconAlgorithm','sqp'...
                                    );
                                
                                mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
                                rSquared = mdl.Rsquared.Ordinary;
                                
                                rSquaredPooled(initialTransient, initialSustained, initialPersistent) = rSquared;
                            end
                        end
                    end
                    % determine which configuration gave the best fit, judged by
                    % rSquared value
                    [maxValue, maxIndex] = max(rSquaredPooled(:));
                    [index1, index2, index3] = ind2sub(size(rSquaredPooled), maxIndex);
                    bestInitialValues = [-200, 350, 5, startingValues(index1), startingValues(index2), startingValues(index3)];
                    
                    % do the fit with the best initialValues
                    thePacket.response.values = withinBlockAverage*100;
                    [paramsFit,fVal,modelResponseStruct] = ...
                        temporalFit.fitResponse(thePacket, ...
                        'defaultParamsInfo', defaultParamsInfo, ...
                        'vlb', vlb, 'vub',vub,...
                        'initialValues',bestInitialValues,...
                        'fminconAlgorithm','sqp'...
                        );
                    
                    totalResponseArea = paramsFit.paramMainMatrix(4) + paramsFit.paramMainMatrix(5) + paramsFit.paramMainMatrix(6);
                    totalResponseStruct{session}.(stimuli{stimulus})(subject, withinBlockIndex) = totalResponseArea;
                end
            end
        end
    end
end


%% do some plotting
close all
stimuli = {'Melanopsin', 'LMS'};

colors = {'c-o', 'k-o'};
for stimulus = 1:2
    plotFig = figure;
    title(stimuli{stimulus})
    for session = 1:3
        ax{session} = subplot(1,3,session);
        numberOfSubjects = size(totalResponseStruct{session}.(stimuli{stimulus}),2);
        
        
        
        
        errBar = [];
        errBar(1,:) = nanstd(totalResponseStruct{session}.(stimuli{stimulus}), [], 1)/sqrt(numberOfSubjects);
        errBar(2,:) = nanstd(totalResponseStruct{session}.(stimuli{stimulus}), [], 1)/sqrt(numberOfSubjects);
        
        
        shadedErrorBar(1:6, mean(totalResponseStruct{session}.(stimuli{stimulus}),1), errBar, 'LineProps', colors{stimulus});
        title(['Session ' num2str(session)]);
        xlabel('Trial Number')
        ylabel('Total Response Area')
        
        
    end
    linkaxes([ax{1}, ax{2}, ax{3}])
    xlim([0.9 6.1])
    %suptitle(stimuli{stimulus})
    
end

for stimulus = 1:2
    plotFig = figure;
    title(stimuli{stimulus})
        numberOfSubjects = (size(totalResponseStruct{1}.(stimuli{stimulus}),2) + size(totalResponseStruct{2}.(stimuli{stimulus}),2) + size(totalResponseStruct{3}.(stimuli{stimulus}),2));
        
        
        
        
        errBar = [];
        errBar(1,:) = nanstd([totalResponseStruct{1}.(stimuli{stimulus}); totalResponseStruct{2}.(stimuli{stimulus}); totalResponseStruct{3}.(stimuli{stimulus})], [], 1)/sqrt(numberOfSubjects);
        errBar(2,:) = nanstd([totalResponseStruct{1}.(stimuli{stimulus}); totalResponseStruct{2}.(stimuli{stimulus}); totalResponseStruct{3}.(stimuli{stimulus})], [], 1)/sqrt(numberOfSubjects);
        
        
        shadedErrorBar(1:6, mean([totalResponseStruct{1}.(stimuli{stimulus}); totalResponseStruct{2}.(stimuli{stimulus}); totalResponseStruct{3}.(stimuli{stimulus})],1), errBar, 'LineProps', colors{stimulus});
        title(stimuli{stimulus});
        xlabel('Trial Number')
        ylabel('Total Response Area')
        
        
    
    xlim([0.9 6.1])
    ylim([-160 0])
    %suptitle(stimuli{stimulus})
    
end


