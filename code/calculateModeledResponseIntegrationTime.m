function [responseIntegrationTime] = calculateModeledResponseIntegrationTime(goodSubjects, totalResponseArea, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('makePlot',false,@islogical);


p.parse(varargin{:});


stimuli = {'LMS', 'Mel', 'Blue', 'Red'};

for session = 1:3
    for stimulus = 1:length(stimuli)
        for ss = 1:length(TPUPParameters{session}.(stimuli{stimulus}).delay)
            % from the TPUP fit, determine the minimum value
            temporalFit = tfeTPUP('verbosity','none');
            % set up the parameters of the model fit from that individual
            % subject
            params0 = temporalFit.defaultParams;
            params0.paramMainMatrix(1) = TPUPParameters{session}.(stimuli{stimulus}).delay(ss);
            params0.paramMainMatrix(2) = TPUPParameters{session}.(stimuli{stimulus}).gammaTau(ss);
            params0.paramMainMatrix(3) = TPUPParameters{session}.(stimuli{stimulus}).exponentialTau(ss);
            params0.paramMainMatrix(4) = TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude(ss);
            params0.paramMainMatrix(5) = TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude(ss);
            params0.paramMainMatrix(6) = TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss);
            
            % add stimulus information
            stepOnset = 1000; % in msec
            stepOffset = 4000; % in msec
            timebase = 0:20:13980;
            [stimulusStruct] = makeStepPulseStimulusStruct(timebase, stepOnset, stepOffset, 'rampDuration', 500);
            
            
            
            modelResponseStruct=temporalFit.computeResponse(params0,stimulusStruct,[]);
            minimumFittedValue = min(modelResponseStruct.values);
            
            responseIntegrationTime{session}.(stimuli{stimulus})(ss) = totalResponseArea{session}.(stimuli{stimulus})(ss)/minimumFittedValue;
        end
    end
end

stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
comparison1 = {1, 1, 2};
comparison2 = {2, 3, 3};

if p.Results.makePlot
    for comparison = 1:length(comparison1)
        for stimulus = 1:length(stimuli)
            
            minX = min(totalResponseArea{comparison1{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison1{comparison}}.(stimuli{stimulus}));
            maxX = max(totalResponseArea{comparison1{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison1{comparison}}.(stimuli{stimulus}));
            minY = min(totalResponseArea{comparison2{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison2{comparison}}.(stimuli{stimulus}));
            maxY = max(totalResponseArea{comparison2{comparison}}.(stimuli{stimulus})./amplitudesPerSubject{comparison2{comparison}}.(stimuli{stimulus}));
            maxValue = max([maxX, maxY]);
            minValue = min([minX, minY]);
            
            [ pairedResponseIntegrationTime ] = pairResultAcrossSessions(goodSubjects{comparison1{comparison}}.ID, goodSubjects{comparison2{comparison}}.ID, responseIntegrationTime{comparison1{comparison}}.(stimuli{stimulus}), responseIntegrationTime{comparison2{comparison}}.(stimuli{stimulus}), dropboxAnalysisDir, 'subdir', 'responseIntegrationTime/modeled', 'saveName', [stimuli{stimulus}, '_', num2str(comparison1{comparison}), 'x', num2str(comparison2{comparison})], 'xLims', [0 8], 'yLims', [0 8]);
            
        end
    end
end

if p.Results.makePlot
    for session = 1:3
        plotFig = figure;
        hold on
        bplot(responseIntegrationTime{session}.LMS, 1, 'color', 'k')
        bplot(responseIntegrationTime{session}.Mel, 2, 'color', 'c')
        bplot(responseIntegrationTime{session}.Blue, 3, 'color', 'b')
        bplot(responseIntegrationTime{session}.Red, 4, 'color', 'r')
        xticks([1, 2, 3, 4])
        xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
        saveas(plotFig, fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/responseIntegrationTime/modeled', ['compareStimuli_responseIntegrationTime_', num2str(session), '.png']), 'png');
        close(plotFig)
    end
end

end % end function