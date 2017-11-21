function makeFigures(goodSubjects, averageResponsePerSubject, groupAverageResponse, TPUPParameters, TPUPParameters_fixedTemporalParameters, dropboxAnalysisDir)

%% Set up some basic variables
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

colors = {'c', 'k', 'b', 'r'};
stimuli = {'Mel', 'LMS', 'Blue', 'Red'};
timebase = 0:20:13980;

confidenceInterval = {10, 90};

% make group median responses
for session = 1:3
    for stimulus = 1:length(stimuli)
        for tt = 1:length(averageResponsePerSubject{session}.(stimuli{stimulus})(1,:))
            groupMedianResponse{session}.(stimuli{stimulus})(tt) = median(averageResponsePerSubject{session}.(stimuli{stimulus})(:,tt));
            sortedTimepoint = [];
            sortedTimepoint = sort(averageResponsePerSubject{session}.(stimuli{stimulus})(:,tt));
            groupMedianResponse{session}.([stimuli{stimulus}, '_25'])(tt) = sortedTimepoint(round(length(averageResponsePerSubject{session}.(stimuli{stimulus})(:,tt))*0.25));
            groupMedianResponse{session}.([stimuli{stimulus}, '_75'])(tt) = sortedTimepoint(round(length(averageResponsePerSubject{session}.(stimuli{stimulus})(:,tt))*0.75));

        end
    end
end
%% Figure 1: experimental overview

%% Figure 2: group average response shapes from session 1 and 2
% a.: Group average responses, +/- SEM



plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])
for session = 1:2
    for stimulus = 1:length(stimuli)
        subplotIndex = (session-1)*4 + stimulus;
        subplot(2,4, subplotIndex)
        pbaspect([1 1 1])
        
        hold on
        
        if session == 1
            title(stimuli{stimulus})
        end
        
        xlim([ 0 15000])
        ylim([-50 10])
        
        if subplotIndex == 1 || subplotIndex == 5
            ylabel('Pupil Diameter (% Change)')
        end
        xlabel('Time (s)')
        
        errBar = [];
        
        % for median approach:
        %errBar(2,:) = groupMedianResponse{session}.(stimuli{stimulus}) - groupMedianResponse{session}.([stimuli{stimulus}, '_25']);
        %errBar(1,:) = groupMedianResponse{session}.([stimuli{stimulus}, '_75']) - groupMedianResponse{session}.(stimuli{stimulus});
        
        errBar(1,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);
        errBar(2,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);
        
        shadedErrorBar(timebase, groupAverageResponse{session}.(stimuli{stimulus}) * 100, errBar*100, 'LineProps', ['-', colors{stimulus}])
        
        
        line([1000 4000], [5 5], 'LineWidth', 4, 'Color', 'k');
        xticks([0, 5000, 10000, 15000])
        xticklabels([0, 5, 10, 15])
    end
end
%suptitle('Reproducibility of group average responses')

print(plotFig, fullfile(outDir,'2a_groupAverageResponses_perStimulus_perSession_withSEM'), '-dpdf', '-bestfit')
close(plotFig)

% b: Reproducibility of group average response shapes
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])


for stimulus = 1:length(stimuli)
    subplot(1,4,stimulus)
    pbaspect([1 1 1])
    hold on
    timebase = 0:20:13980;
    
    first = plot(timebase, groupAverageResponse{1}.(stimuli{stimulus})*100, 'Color', colors{stimulus}, 'LineWidth', 2);
    hold on
    second = plot(timebase, groupAverageResponse{2}.(stimuli{stimulus})*100, 'Color', colors{stimulus});
    first.Color(4) = 0.2;
    % now adjust the plot a bit
    if stimulus == 1
        leg = legend({'First Session', 'Second Session'}, 'Location', 'SouthEast','FontSize', 5);
        ylabel('Pupil Diameter (% Change)')
    end
    xlabel('Time (s)')
    
    ylim([-50 10])
    xlim([0 15000])
    title([stimuli{stimulus}])
    xticks([0, 5000, 10000, 15000])
    xticklabels([0, 5, 10, 15])
    
end
%suptitle('Reproducibility of group average responses')

print(plotFig, fullfile(outDir,'2b_reproducibilityOfGroupAverageResponse'), '-dpdf', '-bestfit')
close(plotFig)

%% Figure 3: Model fits
% For now, just model fits for the first session of data
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])

session = 1;
for stimulus = 1:length(stimuli)
    
    subplot(1,4,stimulus)
    pbaspect([1 1 1])
    hold on
    timebase = 0:20:13980; % in msec
    average = plot(timebase, groupAverageResponse{session}.(stimuli{stimulus})*100, 'Color', colors{stimulus}, 'LineWidth', 2);
    average.Color(4) = 0.2;
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
        leg = legend([average, model], 'Session 1 Group Average', 'Average Model Fit', 'Location', 'SouthEast');
        leg.FontSize = 5;
        
        ylabel('Pupil Diameter (% Change)')
    end
    xlabel('Time (s)')
    
    ylim([-50 10])
    xlim([0 15000])
    title([stimuli{stimulus}])
    xticks([0, 5000, 10000, 15000])
    xticklabels([0, 5, 10, 15])
end

%suptitle('TPUP Model Fits')
print(plotFig, fullfile(outDir,'3_TPUPFits'), '-dpdf', '-bestfit')
close(plotFig)

%% Figure 4: Group comparisons of exponential tau and percent persistent
% Exponential tau
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuli)
    [ combinedExponentialTau.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).exponentialTau, TPUPParameters{2}.(stimuli{stimulus}).exponentialTau);
end

subplot(1,2,1)
pbaspect([1 1 1])


data = horzcat(combinedExponentialTau.Mel.result', combinedExponentialTau.LMS.result', combinedExponentialTau.Blue.result', combinedExponentialTau.Red.result');
plotSpread(data, 'distributionColors', {'c', 'k', 'b', 'r'}, 'xNames', {'Mel', 'LMS', 'Blue', 'Red'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)


[ significanceMelLMS ] = evaluateSignificanceOfMedianDifference(combinedExponentialTau.Mel.result, combinedExponentialTau.LMS.result, dropboxAnalysisDir);

% is exponentialTau of blue significantly greater than that of red?
[ significanceBlueRed ] = evaluateSignificanceOfMedianDifference(combinedExponentialTau.Blue.result, combinedExponentialTau.Red.result, dropboxAnalysisDir);
string = sprintf(['Mel - LMS:  p = ',num2str(significanceMelLMS, 2), '\nBlue - Red: p = ', num2str(significanceBlueRed, 2)]);

text(0.1, 18.5, string, 'FontSize', 7)



ylabel('Exponential Tau')

for stimulus = 1:length(stimuli)
    [ combinedPercentPersistent.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, (TPUPParameters{1}.(stimuli{stimulus}).persistentAmplitude./(TPUPParameters{1}.(stimuli{stimulus}).transientAmplitude + TPUPParameters{1}.(stimuli{stimulus}).sustainedAmplitude + TPUPParameters{1}.(stimuli{stimulus}).persistentAmplitude))*100, (TPUPParameters{2}.(stimuli{stimulus}).persistentAmplitude./(TPUPParameters{2}.(stimuli{stimulus}).transientAmplitude + TPUPParameters{2}.(stimuli{stimulus}).sustainedAmplitude + TPUPParameters{2}.(stimuli{stimulus}).persistentAmplitude))*100);
end
subplot(1,2,2)


data = horzcat(combinedPercentPersistent.Mel.result', combinedPercentPersistent.LMS.result', combinedPercentPersistent.Blue.result', combinedPercentPersistent.Red.result');
plotSpread(data, 'distributionColors', {'c', 'k', 'b', 'r'}, 'xNames', {'Mel', 'LMS', 'Blue', 'Red'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)

[ significanceMelLMS ] = evaluateSignificanceOfMedianDifference(combinedPercentPersistent.Mel.result, combinedPercentPersistent.LMS.result, dropboxAnalysisDir);
% is exponentialTau of blue significantly greater than that of red?
[ significanceBlueRed ] = evaluateSignificanceOfMedianDifference(combinedPercentPersistent.Blue.result, combinedPercentPersistent.Red.result, dropboxAnalysisDir);
string = sprintf(['Mel - LMS:  p = ',num2str(significanceMelLMS, 2), '\nBlue - Red: p = ', num2str(significanceBlueRed, 2)]);
text(0.1, 96, string, 'FontSize', 7)


ylabel('Percent Persistent')
ylim([0 100])


print(plotFig, fullfile(outDir,'4_compareStimuli'), '-dpdf', '-bestfit')
close(plotFig)



%% Figure 5: Session 3 results at higher light levels
% first showing average responses, +/- SEM
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])
session = 3;
for stimulus = 1:length(stimuli)
    subplotIndex = stimulus;
    subplot(1,4, subplotIndex)
    pbaspect([1 1 1])
    
    hold on
    
    title(stimuli{stimulus})
    
    
    xlim([ 0 15000])
    ylim([-50 10])
    if stimulus == 1
        ylabel('Pupil Diameter (% Change)')
    end
    xlabel('Time (ss)')
    xticks([0, 5000, 10000, 15000])
    xticklabels([0, 5, 10, 15])
    errBar = [];
    
    % for median approach
    %errBar(2,:) = groupMedianResponse{session}.(stimuli{stimulus}) - groupMedianResponse{session}.([stimuli{stimulus}, '_25']);
    %errBar(1,:) = groupMedianResponse{session}.([stimuli{stimulus}, '_75']) - groupMedianResponse{session}.(stimuli{stimulus});
     errBar(1,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);
     errBar(2,:) = groupAverageResponse{session}.([stimuli{stimulus}, '_SEM']);   
    
    shadedErrorBar(timebase, groupAverageResponse{session}.(stimuli{stimulus}) * 100, errBar*100, 'LineProps', ['-', colors{stimulus}])
    
    
    line([1000 4000], [5 5], 'LineWidth', 4, 'Color', 'k');
    
end
%suptitle('Session 3 Group Average Responses at Higher Light Levels')

print(plotFig, fullfile(outDir,'5a_session3AverageResponses'), '-dpdf', '-bestfit')
close(plotFig)

% now showing reproducibility of shape of response from sessions 1/2 and
% session 3
for stimulus = 1:length(stimuli)
    for tt = 1:length(timebase)
        [combinedResultAtTimepoint] = combineResultAcrossSessions(goodSubjects, averageResponsePerSubject{1}.(stimuli{stimulus})(:, tt), averageResponsePerSubject{2}.(stimuli{stimulus})(:, tt));
        combinedGroupAverageResponse.(stimuli{stimulus})(tt) = nanmean(combinedResultAtTimepoint.result);
    end
end

plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])
for stimulus = 1:length(stimuli)
    subplot(1,4,stimulus)
    pbaspect([1 1 1])
    hold on
    
    timebase = 0:20:13980;
    

    
    firstsecond = plot(timebase, combinedGroupAverageResponse.(stimuli{stimulus})*100, 'Color', colors{stimulus}, 'LineWidth', 2);
    hold on
    third = plot(timebase, groupAverageResponse{3}.(stimuli{stimulus})*100, 'Color', colors{stimulus});
    firstsecond.Color(4) = 0.2;
    
    % now adjust the plot a bit
    if stimulus == 1
        leg = legend('Session 1/2 Combined', 'Session 3', 'Location', 'SouthEast');
        leg.FontSize = 5;
        ylabel('Pupil Diameter (% Change)')
    end
    xlabel('Time (s)')
    
    ylim([-50 10])
    xlim([0 15000])
    xticks([0, 5000, 10000, 15000])
    xticklabels([0, 5, 10, 15])
    title([stimuli{stimulus}])
    
end
%suptitle('Reproducibility of group average response at higher light levels')
print(plotFig, fullfile(outDir,'5b_reproducibilityOfSession12With3'), '-dpdf', '-bestfit')
close(plotFig)

%% Appendix
% does the group differernces in percent persistent hold up even if we lock
% the temporal paramters in comparing the mel response to the lms repsonse,
% and the blue to red?
for stimulus = 1:length(stimuli)
    [ combinedPercentPersistent.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, (TPUPParameters_fixedTemporalParameters{1}.(stimuli{stimulus}).persistentAmplitude./(TPUPParameters_fixedTemporalParameters{1}.(stimuli{stimulus}).transientAmplitude + TPUPParameters_fixedTemporalParameters{1}.(stimuli{stimulus}).sustainedAmplitude + TPUPParameters_fixedTemporalParameters{1}.(stimuli{stimulus}).persistentAmplitude))*100, (TPUPParameters_fixedTemporalParameters{2}.(stimuli{stimulus}).persistentAmplitude./(TPUPParameters_fixedTemporalParameters{2}.(stimuli{stimulus}).transientAmplitude + TPUPParameters_fixedTemporalParameters{2}.(stimuli{stimulus}).sustainedAmplitude + TPUPParameters_fixedTemporalParameters{2}.(stimuli{stimulus}).persistentAmplitude))*100);
end
plotFig = figure;


data = horzcat(combinedPercentPersistent.LMS.result', combinedPercentPersistent.Mel.result', combinedPercentPersistent.Blue.result', combinedPercentPersistent.Red.result');
plotSpread(data, 'distributionColors', {'k', 'c', 'b', 'r'}, 'xNames', {'LMS', 'Mel', 'Blue', 'Red'}, 'distributionMarkers', 'o', 'showMM', 1)

[ significanceMelLMS ] = evaluateSignificanceOfMedianDifference(combinedPercentPersistent.Mel.result, combinedPercentPersistent.LMS.result, dropboxAnalysisDir);
% is exponentialTau of blue significantly greater than that of red?
[ significanceBlueRed ] = evaluateSignificanceOfMedianDifference(combinedPercentPersistent.Blue.result, combinedPercentPersistent.Red.result, dropboxAnalysisDir);
string = sprintf(['Mel - LMS:  p = ',num2str(significanceMelLMS, 2), '\nBlue - Red: p = ', num2str(significanceBlueRed, 2)]);
text(0.1, 96, string, 'FontSize', 12)

title('Percent Persistent')
ylabel('Percent Persistent P/(T+S+P) (%), Session 1/2 Combined')
ylim([0 100])



print(plotFig, fullfile(outDir,'appendix_percentPersistent_temporalParametersFixed'), '-dpdf', '-bestfit')
close(plotFig)

% correlation of mel/lms response ratio from sessions 1/2
sessionOneErrorBar = [];
sessionOneErroBar(1,:) = TPUPParameters{1}.MeltoLMS.totalResponseArea - TPUPParameters{1}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{1})]);
sessionOneErroBar(2,:) = TPUPParameters{1}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{2})]) - TPUPParameters{1}.MeltoLMS.totalResponseArea;

sessionTwoErrorBar = [];
sessionTwoErroBar(1,:) = TPUPParameters{2}.MeltoLMS.totalResponseArea - TPUPParameters{2}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{1})]);
sessionTwoErroBar(2,:) = TPUPParameters{2}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{2})]) - TPUPParameters{2}.MeltoLMS.totalResponseArea;

[ pairedTotalResponseAreaNormed ] = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, TPUPParameters{1}.MeltoLMS.totalResponseArea, TPUPParameters{2}.MeltoLMS.totalResponseArea, dropboxAnalysisDir, 'sessionOneErrorBar', sessionOneErroBar, 'sessionTwoErrorBar', sessionTwoErroBar, 'subdir', 'figures', 'saveName', ['appendix_melToLMS_1x2'], 'xLim', [0 4.5], 'yLim', [0 4.5], 'plotOption', 'square', 'xLabel', ['Session 1 Mel/LMS Total Response Area'], 'yLabel', ['Session 2 Mel/LMS Total Response Area'], 'title', 'Reproducibility of Mel/LMS Response Ratio');
[ CI, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, pairedTotalResponseAreaNormed.sessionOne, pairedTotalResponseAreaNormed.sessionTwo, dropboxAnalysisDir);


% correlation of mel/lms response ratio from sessions 1/2 combined with
% session 3
[ combinedTotalResponseArea.MeltoLMS ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.MeltoLMS.totalResponseArea, TPUPParameters{2}.MeltoLMS.totalResponseArea);
[ combinedTotalResponseArea_lowerBound.MeltoLMS ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.MeltoLMS.(['totalResponseArea_', num2str(confidenceInterval{1})]), TPUPParameters{2}.MeltoLMS.(['totalResponseArea_', num2str(confidenceInterval{1})]));
[ combinedTotalResponseArea_upperBound.MeltoLMS ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.MeltoLMS.(['totalResponseArea_', num2str(confidenceInterval{2})]), TPUPParameters{2}.MeltoLMS.(['totalResponseArea_', num2str(confidenceInterval{2})]));

session12error = [];
session12error(1,:) = combinedTotalResponseArea.MeltoLMS.result - combinedTotalResponseArea_lowerBound.MeltoLMS.result;
session12error(2,:) = combinedTotalResponseArea_upperBound.MeltoLMS.result - combinedTotalResponseArea.MeltoLMS.result;

session3error = [];
session3error(1,:) = TPUPParameters{3}.MeltoLMS.totalResponseArea - TPUPParameters{3}.MeltoLMS.(['totalResponseArea_', num2str(confidenceInterval{1})]);
session3error(2,:) = TPUPParameters{3}.MeltoLMS.(['totalResponseArea_', num2str(confidenceInterval{2})]) - TPUPParameters{3}.MeltoLMS.totalResponseArea;

plotFig = figure;
[ pairedResult12x3 ] = pairResultAcrossSessions(combinedTotalResponseArea.MeltoLMS.subjectKey, goodSubjects{3}.ID, combinedTotalResponseArea.MeltoLMS.result, TPUPParameters{3}.MeltoLMS.totalResponseArea, dropboxAnalysisDir, 'xLims', [0 4.5], 'yLims', [0 4.5], 'sessionOneErrorBar', session12error, 'sessionTwoErrorBar', session3error, 'subdir', 'figures', 'xLabel', ['Mel/LMS Session 1/2 Total Response Area'], 'yLabel', ['Mel/LMS Session 3 Total Response Area'])
[ CI, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, pairedResult12x3.sessionOne, pairedResult12x3.sessionTwo, dropboxAnalysisDir);


title('Reproducibility of Mel/LMS Response Ratio at Higher Light Level')
saveas(plotFig, fullfile(outDir, 'appendix_melToLMS_12x3.pdf'), 'pdf')

plotFig = figure;
lims = {-200, -200, -375, -375};
for stimulus = 1:2
    subplot(1 ,2, stimulus)
    [ combinedTotalResponseArea.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).totalResponseArea, TPUPParameters{2}.(stimuli{stimulus}).totalResponseArea);
    [ combinedTotalResponseArea_lowerBound.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{1})]), TPUPParameters{2}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{1})]));
    [ combinedTotalResponseArea_upperBound.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{2})]), TPUPParameters{2}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{2})]));
    
    session12error = [];
    session12error(1,:) = combinedTotalResponseArea.(stimuli{stimulus}).result - combinedTotalResponseArea_lowerBound.(stimuli{stimulus}).result;
    session12error(2,:) = combinedTotalResponseArea_upperBound.(stimuli{stimulus}).result - combinedTotalResponseArea.(stimuli{stimulus}).result;
    
    session3error = [];
    session3error(1,:) = TPUPParameters{3}.(stimuli{stimulus}).totalResponseArea - TPUPParameters{3}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{1})]);
    session3error(2,:) = TPUPParameters{3}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{2})]) - TPUPParameters{3}.(stimuli{stimulus}).totalResponseArea;
    
    
    pairResultAcrossSessions(combinedTotalResponseArea.(stimuli{stimulus}).subjectKey, goodSubjects{3}.ID, combinedTotalResponseArea.(stimuli{stimulus}).result, TPUPParameters{3}.(stimuli{stimulus}).totalResponseArea, dropboxAnalysisDir, 'xLims', [lims{stimulus} 0], 'yLims', [lims{stimulus} 0], 'sessionOneErrorBar', session12error, 'sessionTwoErrorBar', session3error, 'subdir', 'figures')
    if stimulus == 1
        ylabel('Session 3 Total Response Area')
    end
    xlabel('Session 1/2 Total Response Area')
    title(stimuli{stimulus})
    
end
saveas(plotFig, fullfile(outDir, ['appendix_totalResponseAreaReproducibility_12x3.pdf']), 'pdf')
    close(plotFig)

end % end function