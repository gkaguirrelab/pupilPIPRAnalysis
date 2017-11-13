function makeFigures(goodSubjects, averageResponsePerSubject, groupAverageResponse, TPUPParameters, dropboxAnalysisDir)

%% Set up some basic variables
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

colors = {'k', 'c', 'b', 'r'};
stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
timebase = 0:20:13980;

confidenceInterval = {10 90};
%% Figure 1: experimental overview

%% Figure 2: group average response shapes from session 1 and 2
% a.: Group average responses, +/- SEM

plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])
for session = 1:2
    for stimulus = 1:length(stimuli)
        subplotIndex = (session-1)*4 + stimulus;
        subplot(2,4, subplotIndex)
        
        hold on
        
        if session == 1
            title(stimuli{stimulus})
        end
        
        xlim([ 0 14000])
        ylim([-50 10])
        ylabel('Pupil Diameter (% Change)')
        xlabel('Time (ms)')
        
        errBar(1,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);
        errBar(2,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);
        
        shadedErrorBar(timebase, groupAverageResponse{session}.(stimuli{stimulus}) * 100, errBar*100, 'LineProps', ['-', colors{stimulus}])
        
        
        line([1000 4000], [5 5], 'LineWidth', 4, 'Color', 'k');
        
    end
end
print(plotFig, fullfile(outDir,'2a_groupAverageResponses_perStimulus_perSession_withSEM'), '-dpdf', '-bestfit')
close(plotFig)

% b: Reproducibility of group average response shapes
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])


for stimulus = 1:length(stimuli)
    subplot(1,4,stimulus)
    
    timebase = 0:20:13980;
    
    plot(timebase, groupAverageResponse{1}.(stimuli{stimulus})*100, '-.', 'Color', [0.4, 0.4, 0.4], 'LineWidth', 4)
    hold on
    plot(timebase, groupAverageResponse{2}.(stimuli{stimulus})*100, 'Color', colors{stimulus})
    
    % now adjust the plot a bit
    if stimulus == 1
        legend('First Session', 'Second Session', 'Location', 'SouthEast')
    end
    xlabel('Time (ms)')
    ylabel('Pupil Diameter (% Change)')
    ylim([-50 10])
    xlim([0 14000])
    title([stimuli{stimulus}])
    
end
print(plotFig, fullfile(outDir,'2b_reproducibilityOfGroupAverageResponse'), '-dpdf', '-bestfit')
close(plotFig)

%% Figure 3: Model fits
% For now, just model fits for the first session of data
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])

session = 1;
for stimulus = 1:length(stimuli)
    
    subplot(1,4,stimulus)
    hold on
    timebase = 0:20:13980; % in msec
    average = plot(timebase, groupAverageResponse{session}.(stimuli{stimulus})*100, '--', 'Color', colors{stimulus}, 'LineWidth', 3);
    
    % make the TPUP fit from the median parameters
    temporalFit = tfeTPUP('verbosity','none');
    params0 = temporalFit.defaultParams;
    params0.paramMainMatrix(1) = median(TPUPParameters{session}.(stimuli{stimulus}).delay);
    params0.paramMainMatrix(2) = median(TPUPParameters{session}.(stimuli{stimulus}).gammaTau);
    params0.paramMainMatrix(3) = median(TPUPParameters{session}.(stimuli{stimulus}).exponentialTau);
    params0.paramMainMatrix(4) = median(TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude);
    params0.paramMainMatrix(5) = median(TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude);
    params0.paramMainMatrix(6) = median(TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude);
    
    
    stepOnset = 1000; % in msec
    stepOffset = 4000; % in msec
    [stimulusStruct] = makeStepPulseStimulusStruct(timebase, stepOnset, stepOffset, 'rampDuration', 500);
    
    
    tmpParams=params0;
    tmpParams.paramMainMatrix([5,6])=0;
    modelResponseStruct=temporalFit.computeResponse(tmpParams,stimulusStruct,[]);
    plot(timebase, modelResponseStruct.values,'Color',[1 .25 .25])
    tmpParams=params0;
    tmpParams.paramMainMatrix([4,6])=0;
    modelResponseStruct=temporalFit.computeResponse(tmpParams,stimulusStruct,[]);
    plot(timebase, modelResponseStruct.values,'Color',[1 .5 .5])
    tmpParams=params0;
    tmpParams.paramMainMatrix([4,5])=0;
    modelResponseStruct=temporalFit.computeResponse(tmpParams,stimulusStruct,[]);
    plot(timebase, modelResponseStruct.values,'Color',[1 .75 .75]);
    
    modelResponseStruct=temporalFit.computeResponse(params0,stimulusStruct,[]);
    model = plot(timebase, modelResponseStruct.values, 'Color', colors{stimulus});
    if stimulus == 1
        legend([average, model], 'Session 1 Group Average', 'Median Model Fit', 'Location', 'SouthEast')
    end
    xlabel('Time (ms)')
    ylabel('Pupil Diameter (% Change)')
    ylim([-50 10])
    xlim([0 14000])
    title([stimuli{stimulus}])
end

print(plotFig, fullfile(outDir,'3_TPUPFits'), '-dpdf', '-bestfit')
close(plotFig)

%% Figure 4: Group comparisons of exponential tau and percent persistent

end % end function