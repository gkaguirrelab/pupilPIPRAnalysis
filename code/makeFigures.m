function makeFigures(goodSubjects, averageResponsePerSubject, groupAverageResponse, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir)

%% Set up some basic variables
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

confidenceInterval = {10 90};
%% Figure 1: the average response at the group level shows characteristic features that differentiate the responses to each stimulus. These responses are also reproducible

stimuli = {'LMS' 'Mel' 'Blue' 'Red'};
plotFig = figure;


for stimulus = 1:length(stimuli)
    subplot(2,2,stimulus)
    
    timebase = 0:20:13980;
    
    plot(timebase, groupAverageResponse{1}.(stimuli{stimulus})*100, '-.', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 3)
    hold on
    plot(timebase, groupAverageResponse{2}.(stimuli{stimulus})*100, 'Color', 'b')
    
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

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['1a_groupAverageResponseReproducibility_sameColors.pdf']), 'pdf');
close(plotFig)

% 1 b.: we can use our three component model to fit the shapes of these
% responses
colors = {'k', 'c', 'b', 'r'};
for session = 1:3
    plotFig = figure;
    for stimulus = 1:length(stimuli)
        
        subplot(2,2,stimulus)
        hold on
        timebase = 0:20:13980; % in msec
        plot(timebase, groupAverageResponse{session}.(stimuli{stimulus})*100, 'Color', colors{stimulus})
        
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
        plot(timebase, modelResponseStruct.values, 'Color', 'g')
        if stimulus == 1
            legend('Session 1 Group Average', 'Median Model Fit', 'Location', 'SouthEast')
        end
        xlabel('Time (ms)')
        ylabel('Pupil Diameter (% Change)')
        ylim([-50 10])
        xlim([0 14000])
        title([stimuli{stimulus}])
    end
    suptitle(['Session ' num2str(session)])
    set(gcf,'Renderer','painters')
    saveas(plotFig, fullfile(outDir, ['1b_groupAverageTPUPFits_session', num2str(session), '.pdf']), 'pdf');
    close(plotFig)
end



%% Figure 2: stimuli that produces a relatively larger melanopsin response are different in this quantitative way
% The general idea is that consistent with electrophysiologic properties
% (slow kinetics) observed upon melanopsin activation in ipRGCs, we've
% devised a modeling approach that allows us to quantify these slower
% temporal dynamics within our pupil response. Specifically our three
% component pupil model fits the pupil response on the basis of three
% temporally distinct components. We calculate the percent persistent,
% which is the amplitude of the persistent component divided by the total
% response area (the sum of all three components). Note that these data
% aren't normally distributed, so we've decided to use median as our
% measure of the central tendency.
% Also note that here I will be collapsing session 1 and 2 together
% (for subjects studied twice, calculating the average percent persistent
% for both sessions)

% calculate percentPersistent for each subject based on the TPUP results
[ percentPersistentPerSubject ] = calculatePercentPersistent(goodSubjects, TPUPParameters, dropboxAnalysisDir);

% combine session 1 and session 2
stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
for stimulus = 1:length(stimuli)
    [ combinedPercentPersistent.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, percentPersistentPerSubject{1}.(stimuli{stimulus}), percentPersistentPerSubject{2}.(stimuli{stimulus}));
end

% now do the plotting:
plotFig = figure;
hold on
bplot(combinedPercentPersistent.LMS.result, 1, 'color', 'k')
bplot(combinedPercentPersistent.Mel.result, 2, 'color', 'c')
bplot(combinedPercentPersistent.Blue.result, 3, 'color', 'b')
bplot(combinedPercentPersistent.Red.result, 4, 'color', 'r')
xticks([1, 2, 3, 4])
xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
xlabel('Stimulus')
ylabel('Percent Persistent (P/(T+S+P)x100%)')
title('Session 1/2 Combined')

% evaluate significance of median differences:
% is percent persistent of mel significantly greater than that of LMS?
[ significance ] = evaluateSignificanceOfMedianDifference(combinedPercentPersistent.Mel.result, combinedPercentPersistent.LMS.result, dropboxAnalysisDir);
if significance < 1
    text(1.5, 0.98, '**', 'FontSize', 22)
elseif significance < 5
    text(1.5, 0.98, '*', 'FontSize', 22)
end

% is percent persistent of blue significantly greater than that of red?
[ significance ] = evaluateSignificanceOfMedianDifference(combinedPercentPersistent.Blue.result, combinedPercentPersistent.Red.result, dropboxAnalysisDir);
if significance < 1
    text(3.5, 0.9, '**', 'FontSize', 22)
elseif significance < 5
    text(3.5, 0.9, '*', 'FontSize', 22)
end


saveas(plotFig, fullfile(outDir, ['2_percentPersistent_session1-2Combined.pdf']), 'pdf')
close(plotFig)

for session = 1:3
    plotFig = figure;
    hold on
    bplot(percentPersistentPerSubject{session}.LMS, 1, 'color', 'k')
    bplot(percentPersistentPerSubject{session}.Mel, 2, 'color', 'c')
    bplot(percentPersistentPerSubject{session}.Blue, 3, 'color', 'b')
    bplot(percentPersistentPerSubject{session}.Red, 4, 'color', 'r')
    title(['Session ' num2str(session)])
    xticks([1, 2, 3, 4])
    xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
    xlabel('Stimulus')
    ylabel('Percent Persistent (P/(T+S+P)x100%)')
    
    % evaluate significance of median differences:
    % is percent persistent of mel significantly greater than that of LMS?
    [ significance ] = evaluateSignificanceOfMedianDifference(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.LMS, dropboxAnalysisDir);
    if significance < 1
        text(1.5, 0.98, '**', 'FontSize', 22)
    elseif significance < 5
        text(1.5, 0.98, '*', 'FontSize', 22)
    end
    
    % is percent persistent of blue significantly greater than that of red?
    [ significance ] = evaluateSignificanceOfMedianDifference(percentPersistentPerSubject{session}.Blue, percentPersistentPerSubject{session}.Red, dropboxAnalysisDir);
    if significance < 1
        text(3.5, 0.9, '**', 'FontSize', 22)
    elseif significance < 5
        text(3.5, 0.9, '*', 'FontSize', 22)
    end
    
    saveas(plotFig, fullfile(outDir, ['2_percentPersistent_session', num2str(session), '.pdf']), 'pdf')
    close(plotFig)
end


% across stimulus correlations for exponential tau
% looking at the comparison between LMS and Mel, Blue and Red,
% session 1/2 combined

[ percentPersistent ] = calculatePercentPersistent(goodSubjects, TPUPParameters, dropboxAnalysisDir);
comparisons(1,:) = {'LMS', 'Blue'};
comparisons(2,:) = {'Mel', 'Red'};
for cc = 1:size(comparisons,2)
    xError = [];
    yError = [];
    [ XcombinedPercentPersistent.(comparisons{1,cc}) ] = combineResultAcrossSessions(goodSubjects, percentPersistent{1}.(comparisons{1,cc}), percentPersistent{2}.(comparisons{1,cc}));
    [ XcombinedPercentPersistent_lowerBound.(comparisons{1,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{1,cc}).(['percentPersistent_', num2str(confidenceInterval{1})]), TPUPParameters{2}.(comparisons{1,cc}).(['percentPersistent_', num2str(confidenceInterval{1})]));
    [ XcombinedPercentPersistent_upperBound.(comparisons{1,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{1,cc}).(['percentPersistent_', num2str(confidenceInterval{2})]), TPUPParameters{2}.(comparisons{1,cc}).(['percentPersistent_', num2str(confidenceInterval{2})]));
    xError(1,:) = XcombinedPercentPersistent.(comparisons{1,cc}).result - XcombinedPercentPersistent_lowerBound.(comparisons{1,cc}).result;
    xError(2,:) = XcombinedPercentPersistent_upperBound.(comparisons{1,cc}).result - XcombinedPercentPersistent.(comparisons{1,cc}).result;
    
    % i noticed that the bootstrap distribution of exponential tau could be
    % highly skewed. As a result, I've noticed that the mean of the
    % bootstrap distribution can actually be larger than the 90th
    % percentile. in specifying error bars in this case, i've decided make
    % the error bar not extend from the mean value in that direction
    
    xError(xError<0) = 0;
    
    [ YcombinedPercentPersistent.(comparisons{2,cc}) ] = combineResultAcrossSessions(goodSubjects, percentPersistent{1}.(comparisons{2,cc}), percentPersistent{2}.(comparisons{2,cc}));
    [ YcombinedPercentPersistent_lowerBound.(comparisons{2,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{2,cc}).(['percentPersistent_', num2str(confidenceInterval{1})]), TPUPParameters{2}.(comparisons{2,cc}).(['percentPersistent_', num2str(confidenceInterval{1})]));
    [ YcombinedPercentPersistent_upperBound.(comparisons{2,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{2,cc}).(['percentPersistent_', num2str(confidenceInterval{2})]), TPUPParameters{2}.(comparisons{2,cc}).(['percentPersistent_', num2str(confidenceInterval{2})]));
    yError(1,:) = YcombinedPercentPersistent.(comparisons{2,cc}).result - YcombinedPercentPersistent_lowerBound.(comparisons{2,cc}).result;
    yError(2,:) = YcombinedPercentPersistent_upperBound.(comparisons{2,cc}).result - YcombinedPercentPersistent.(comparisons{2,cc}).result;
    
    yError(yError<0) = 0;
    
    plotFig = figure;
    prettyScatterplots(XcombinedPercentPersistent.(comparisons{1,cc}).result, YcombinedPercentPersistent.(comparisons{2,cc}).result, 'xError', xError, 'yError', yError, 'xLabel', [comparisons{1, cc} ' Percent Persistent'], 'yLabel', [comparisons{2, cc} ' Percent Persistent'], 'plotOption', 'square', 'significance', 'rho', 'unity', 'on', 'xLim', [0 1], 'yLim', [0 1])
    title('Session 1/2 Combined')
    saveas(plotFig, fullfile(outDir, ['2_percentPersistent_', comparisons{1,cc}, 'x', comparisons{2,cc} 'session12Combined.pdf']), 'pdf')
    close(plotFig)
    
end
% each session separately

for session = 1:3
    for cc = 1:size(comparisons,2)
        xError = [];
        yError = [];
        xError(1,:) = percentPersistent{session}.(comparisons{1,cc}) - TPUPParameters{session}.(comparisons{1,cc}).(['percentPersistent_', num2str(confidenceInterval{1})]);
        xError(2,:) = TPUPParameters{session}.(comparisons{1,cc}).(['percentPersistent_', num2str(confidenceInterval{2})]) - percentPersistent{session}.(comparisons{1,cc});
        
        yError(1,:) = percentPersistent{session}.(comparisons{2,cc}) - TPUPParameters{session}.(comparisons{2,cc}).(['percentPersistent_', num2str(confidenceInterval{1})]);
        yError(2,:) = TPUPParameters{session}.(comparisons{2,cc}).(['percentPersistent_', num2str(confidenceInterval{2})]) - percentPersistent{session}.(comparisons{2,cc});
        
        xError(xError<0) = 0;
        yError(yError<0) = 0;
        
        plotFig = figure;
        prettyScatterplots(percentPersistent{session}.(comparisons{1,cc}), percentPersistent{session}.(comparisons{2,cc}), 'xError', xError, 'yError', yError, 'xLabel', [comparisons{1, cc} ' Percent Persistent'], 'yLabel', [comparisons{2, cc} ' Percent Persistent'], 'plotOption', 'square', 'significance', 'rho', 'unity', 'on', 'xLim', [0 1], 'yLim', [0 1])
        title(['Session ' num2str(session)])
        saveas(plotFig, fullfile(outDir, ['2_percentPersistent_', comparisons{1,cc}, 'x', comparisons{2,cc} '_session', num2str(session), '.pdf']), 'pdf')
        close(plotFig)
    end
end



% across stimulus correlations for exponential tau
% looking at the comparison between LMS and Mel, Blue and Red,
% session 1/2 combined
comparisons(1,:) = {'LMS', 'Blue'};
comparisons(2,:) = {'Mel', 'Red'};
for cc = 1:size(comparisons,2)
    xError = [];
    yError = [];
    [ XcombinedExponentialTau.(comparisons{1,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{1,cc}).exponentialTau, TPUPParameters{2}.(comparisons{1,cc}).exponentialTau);
    [ XcombinedExponentialTau_lowerBound.(comparisons{1,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{1,cc}).(['exponentialTau_', num2str(confidenceInterval{1})]), TPUPParameters{2}.(comparisons{1,cc}).(['exponentialTau_', num2str(confidenceInterval{1})]));
    [ XcombinedExponentialTau_upperBound.(comparisons{1,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{1,cc}).(['exponentialTau_', num2str(confidenceInterval{2})]), TPUPParameters{2}.(comparisons{1,cc}).(['exponentialTau_', num2str(confidenceInterval{2})]));
    xError(1,:) = XcombinedExponentialTau.(comparisons{1,cc}).result - XcombinedExponentialTau_lowerBound.(comparisons{1,cc}).result;
    xError(2,:) = XcombinedExponentialTau_upperBound.(comparisons{1,cc}).result - XcombinedExponentialTau.(comparisons{1,cc}).result;
    
    % i noticed that the bootstrap distribution of exponential tau could be
    % highly skewed. As a result, I've noticed that the mean of the
    % bootstrap distribution can actually be larger than the 90th
    % percentile. in specifying error bars in this case, i've decided make
    % the error bar not extend from the mean value in that direction
    
    xError(xError<0) = 0;
    
    [ YcombinedExponentialTau.(comparisons{2,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{2,cc}).exponentialTau, TPUPParameters{2}.(comparisons{2,cc}).exponentialTau);
    [ YcombinedExponentialTau_lowerBound.(comparisons{2,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{2,cc}).(['exponentialTau_', num2str(confidenceInterval{1})]), TPUPParameters{2}.(comparisons{2,cc}).(['exponentialTau_', num2str(confidenceInterval{1})]));
    [ YcombinedExponentialTau_upperBound.(comparisons{2,cc}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(comparisons{2,cc}).(['exponentialTau_', num2str(confidenceInterval{2})]), TPUPParameters{2}.(comparisons{2,cc}).(['exponentialTau_', num2str(confidenceInterval{2})]));
    yError(1,:) = YcombinedExponentialTau.(comparisons{2,cc}).result - YcombinedExponentialTau_lowerBound.(comparisons{2,cc}).result;
    yError(2,:) = YcombinedExponentialTau_upperBound.(comparisons{2,cc}).result - YcombinedExponentialTau.(comparisons{2,cc}).result;
    
    yError(yError<0) = 0;
    
    plotFig = figure;
    prettyScatterplots(XcombinedExponentialTau.(comparisons{1,cc}).result, YcombinedExponentialTau.(comparisons{2,cc}).result, 'xError', xError, 'yError', yError, 'xLabel', [comparisons{1, cc} ' Exponential Tau'], 'yLabel', [comparisons{2, cc} ' Exponential Tau'], 'plotOption', 'square', 'significance', 'rho', 'unity', 'on', 'xLim', [0 20], 'yLim', [0 20])
    title('Session 1/2 Combined')
    saveas(plotFig, fullfile(outDir, ['2_exponentialTau_', comparisons{1,cc}, 'x', comparisons{2,cc} 'session12Combined.pdf']), 'pdf')
    close(plotFig)
    
end
% each session separately

for session = 1:3
    for cc = 1:size(comparisons,2)
        xError = [];
        yError = [];
        xError(1,:) = TPUPParameters{session}.(comparisons{1,cc}).exponentialTau - TPUPParameters{session}.(comparisons{1,cc}).(['exponentialTau_', num2str(confidenceInterval{1})]);
        xError(2,:) = TPUPParameters{session}.(comparisons{1,cc}).(['exponentialTau_', num2str(confidenceInterval{2})]) - TPUPParameters{session}.(comparisons{1,cc}).exponentialTau;
        
        yError(1,:) = TPUPParameters{session}.(comparisons{2,cc}).exponentialTau - TPUPParameters{session}.(comparisons{2,cc}).(['exponentialTau_', num2str(confidenceInterval{1})]);
        yError(2,:) = TPUPParameters{session}.(comparisons{2,cc}).(['exponentialTau_', num2str(confidenceInterval{2})]) - TPUPParameters{session}.(comparisons{2,cc}).exponentialTau;
        
        xError(xError<0) = 0;
        yError(yError<0) = 0;
        
        plotFig = figure;
        prettyScatterplots(TPUPParameters{session}.(comparisons{1,cc}).exponentialTau, TPUPParameters{session}.(comparisons{2,cc}).exponentialTau, 'xError', xError, 'yError', yError, 'xLabel', [comparisons{1, cc} ' Exponential Tau'], 'yLabel', [comparisons{2, cc} ' Exponential Tau'], 'plotOption', 'square', 'significance', 'rho', 'unity', 'on', 'xLim', [0 20], 'yLim', [0 20])
        title(['Session ' num2str(session)])
        saveas(plotFig, fullfile(outDir, ['2_exponentialTau_', comparisons{1,cc}, 'x', comparisons{2,cc} '_session', num2str(session), '.pdf']), 'pdf')
        close(plotFig)
    end
end


% Now looking at exponential tau
for session = 1:3
    plotFig = figure;
    hold on
    bplot(TPUPParameters{session}.LMS.exponentialTau, 1, 'color', 'k')
    bplot(TPUPParameters{session}.Mel.exponentialTau, 2, 'color', 'c')
    bplot(TPUPParameters{session}.Blue.exponentialTau, 3, 'color', 'b')
    bplot(TPUPParameters{session}.Red.exponentialTau, 4, 'color', 'r')
    xticks([1, 2, 3, 4])
    xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
    ylabel('Exponential Tau')
    ylim([0 20])
    title(['Session ' num2str(session)])
    
    % evaluate significance of median differences:
    % is exponentialTau of mel significantly greater than that of LMS?
    [ significance ] = evaluateSignificanceOfMedianDifference(TPUPParameters{session}.Mel.exponentialTau, TPUPParameters{session}.LMS.exponentialTau, dropboxAnalysisDir);
    if significance < 1
        text(1.5, 16, '**', 'FontSize', 22)
    elseif significance < 5
        text(1.5, 16, '*', 'FontSize', 22)
    end
    
    % is exponentialTau of blue significantly greater than that of red?
    [ significance ] = evaluateSignificanceOfMedianDifference(TPUPParameters{session}.Blue.exponentialTau, TPUPParameters{session}.Red.exponentialTau, dropboxAnalysisDir);
    if significance < 1
        text(3.5, 16, '**', 'FontSize', 22)
    elseif significance < 5
        text(3.5, 16, '*', 'FontSize', 22)
    end
    
    saveas(plotFig, fullfile(outDir, ['2_exponentialTau_session', num2str(session), '.pdf']), 'pdf')
    close(plotFig)
end

% session 1 and 2 combined
stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
for stimulus = 1:length(stimuli)
    [ combinedExponentialTau.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).exponentialTau, TPUPParameters{2}.(stimuli{stimulus}).exponentialTau);
end
plotFig = figure;
hold on
bplot(combinedExponentialTau.LMS.result, 1, 'color', 'k')
bplot(combinedExponentialTau.Mel.result, 2, 'color', 'c')
bplot(combinedExponentialTau.Blue.result, 3, 'color', 'b')
bplot(combinedExponentialTau.Red.result, 4, 'color', 'r')
xticks([1, 2, 3, 4])
xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
xlabel('Stimulus')
ylim([0 20])
ylabel('Exponential Tau')
title('Session 1/2 Combined')

% evaluate significance of median differences:
% is exponentialTau of mel significantly greater than that of LMS?
[ significance ] = evaluateSignificanceOfMedianDifference(combinedExponentialTau.Mel.result, combinedExponentialTau.LMS.result, dropboxAnalysisDir);
if significance < 1
    text(1.5, 14, '**', 'FontSize', 22)
elseif significance < 5
    text(1.5, 14, '*', 'FontSize', 22)
end

% is exponentialTau of blue significantly greater than that of red?
[ significance ] = evaluateSignificanceOfMedianDifference(combinedExponentialTau.Blue.result, combinedExponentialTau.Red.result, dropboxAnalysisDir);
if significance < 1
    text(3.5, 14, '**', 'FontSize', 22)
elseif significance < 5
    text(3.5, 14, '*', 'FontSize', 22)
end

saveas(plotFig, fullfile(outDir, ['2_exponentialTau_session1-2Combined.pdf']), 'pdf')
close(plotFig)


%% Figure 3: Subjects varuy in overall pupil responsiveness

[ totalResponseArea ] = calculateTotalResponseArea(TPUPParameters, dropboxAnalysisDir);

plotFig = figure;
title('Subjects vary in overall pupil responsiveness')

% calculate overall responsiveness
[ overallPupilResponsiveness ] = calculateOverallPupilResponsiveness(goodSubjects, totalResponseArea, dropboxAnalysisDir);


% match session 1 results to session 2 results
[ pairedOverallResponsiveness ]  = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, overallPupilResponsiveness{1}, overallPupilResponsiveness{2}, dropboxAnalysisDir, 'xLabel', 'Session 1 Average Responsiveness', 'yLabel', 'Session 2 Average Responsiveness', 'significance', 'rho', 'xLims', [-225 0], 'yLims', [-225 0], 'subdir', 'figures', 'saveName', '3_overallPupilResponsiveness_1x2');


%% Figure 4: Examining individual differences in the melanopsin and blue responses
%make the error bars
sessionOneErrorBar = [];
sessionOneErroBar(1,:) = TPUPParameters{1}.MeltoLMS.totalResponseArea - TPUPParameters{1}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{1})]);
sessionOneErroBar(2,:) = TPUPParameters{1}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{2})]) - TPUPParameters{1}.MeltoLMS.totalResponseArea;

sessionTwoErrorBar = [];
sessionTwoErroBar(1,:) = TPUPParameters{2}.MeltoLMS.totalResponseArea - TPUPParameters{2}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{1})]);
sessionTwoErroBar(2,:) = TPUPParameters{2}.MeltoLMS.(['totalResponseArea_' num2str(confidenceInterval{2})]) - TPUPParameters{2}.MeltoLMS.totalResponseArea;


% 4 a.: Examining the reproducibility of the mel/lms response ratio
[ pairedTotalResponseAreaNormed ] = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, TPUPParameters{1}.MeltoLMS.totalResponseArea, TPUPParameters{2}.MeltoLMS.totalResponseArea, dropboxAnalysisDir, 'sessionOneErrorBar', sessionOneErroBar, 'sessionTwoErrorBar', sessionTwoErroBar, 'subdir', 'figures', 'saveName', ['4a_melToLMS_1x2'], 'xLim', [0 3], 'yLim', [0 3], 'plotOption', 'square', 'xLabel', ['Session 1 Mel/LMS Total Response Area'], 'yLabel', ['Session 2 Mel/LMS Total Response Area'], 'title', 'Reproducibility of Mel/LMS Response Ratio');

% 4 b.: a violin plot showing the distribution of this mel/lms response
% ratio
[ combinedMeltoLMS] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.MeltoLMS.totalResponseArea, TPUPParameters{2}.MeltoLMS.totalResponseArea);
plotFig = figure;
subplot(1,2,1)
distributionPlot(combinedMeltoLMS.result')
ylabel('Mel/LMS Total Response Area')
title('Session 1/2 Combined')
subplot(1,2,2)
s1 = distributionPlot(TPUPParameters{1}.MeltoLMS.totalResponseArea','widthDiv',[2 1],'histOri','left','color','b','showMM',1);
s2 = distributionPlot(gca,TPUPParameters{2}.MeltoLMS.totalResponseArea','widthDiv',[2 2],'histOri','right','color','k','showMM',1);
ylabel('Mel/LMS Total Response Area')
xticks([0.5 1.5])
xticklabels({'Session 1', 'Session 2'})
saveas(plotFig, fullfile(outDir, ['4b_violinPlot_MeltoLMS_session12Combined.pdf']), 'pdf')


% 4 c.: how individual differences in the mel/lms response ratio relate to
% individual differences in the blue/red response ratio
[ combinedMeltoLMS ] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.Mel./totalResponseArea{1}.LMS, totalResponseArea{2}.Mel./totalResponseArea{2}.LMS);
[ combinedBluetoRed ] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.Blue./totalResponseArea{1}.Red, totalResponseArea{2}.Blue./totalResponseArea{2}.Red);

plotFig = figure;
prettyScatterplots(combinedMeltoLMS.result, combinedBluetoRed.result, 'xLim', [0 2], 'yLim', [0 2], 'unity', 'on', 'significance', 'rho', 'plotOption', 'square')
xlabel('Mel/LMS  Total Response Area')
ylabel('Blue/Red Total Response Area')
title('Session 1/2 Combined')
saveas(plotFig, fullfile(outDir, ['4c_meltoLMSxBluetoRed_session1-2Combined.pdf']), 'pdf')
close all

% 4 d.: Examining the reproducibility of the percent persistent, averaged
% across all responses for session 1 to session 2
[ percentPersistentPerSubject ] = calculatePercentPersistent(goodSubjects, TPUPParameters, dropboxAnalysisDir);
for session = 1:2
    for ss = 1:length(percentPersistentPerSubject{session}.LMS)
        averagePercentPersistentAcrossStimuli{session}(ss) = (percentPersistentPerSubject{session}.LMS(ss) + percentPersistentPerSubject{session}.Mel(ss) + percentPersistentPerSubject{session}.Blue(ss) + percentPersistentPerSubject{session}.Red(ss))/4;
    end
end
[ pairedAveragePercentPersistentAcrossStimuli ] = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, averagePercentPersistentAcrossStimuli{1}*100, averagePercentPersistentAcrossStimuli{2}*100, dropboxAnalysisDir, 'subdir', 'figures', 'saveName', ['4d_averagePercentPersistent_1x2'], 'xLim', [0 100], 'yLim', [0 100], 'plotOption', 'square', 'xLabel', ['Session 1 Average Percent Persistent'], 'yLabel', ['Session 2 Average Percent Persistent'], 'title', 'Reproducibility of Average Percent Persistent');


%% Additional Figures to highlight session 3 differences
% Figure 5: is the mel/lms response area ratio reproducible at a higher
% light level?
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
pairResultAcrossSessions(combinedTotalResponseArea.MeltoLMS.subjectKey, goodSubjects{3}.ID, combinedTotalResponseArea.MeltoLMS.result, TPUPParameters{3}.MeltoLMS.totalResponseArea, dropboxAnalysisDir, 'xLims', [0 4.5], 'yLims', [0 4.5], 'sessionOneErrorBar', session12error, 'sessionTwoErrorBar', session3error, 'subdir', 'figures', 'xLabel', ['Mel/LMS Session 1/2 Total Response Area'], 'yLabel', ['Mel/LMS Session 3 Total Response Area'])
title('Reproducibility of Mel/LMS Response Ratio at Higher Light Level')
saveas(plotFig, fullfile(outDir, '5_melToLMS_12x3.pdf'), 'pdf')

% Figure 6: at the higher light level, the PIPR is increased
[piprTotalAreaNormed, netPIPRTotalAreaNormed] = calculatePIPR(goodSubjects, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir, 'computeMethod', 'totalAreaNormed');
[ PIPRCombined ] = combineResultAcrossSessions(goodSubjects, netPIPRTotalAreaNormed{1}, netPIPRTotalAreaNormed{2});
plotFig = figure;
title('PIPR as area under the curve, normalized')
hold on
bplot(PIPRCombined.result, 1)
bplot(netPIPRTotalAreaNormed{3}, 2)
xticks([1, 2])
xticklabels({'Session 1/2 Combined', 'Session 3'})
ylabel('PIPR (Blue-Red)/(Blue+Red)')
saveas(plotFig, fullfile(outDir, '6_PIPRbySession_totalResponseArea.pdf'), 'pdf')

[piprTotalWindowed, netPIPRWindowed] = calculatePIPR(goodSubjects, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir, 'computeMethod', 'window');
[ PIPRCombined ] = combineResultAcrossSessions(goodSubjects, netPIPRWindowed{1}, netPIPRWindowed{2});
plotFig = figure;
title('PIPR as sustained constriction following light offset')
hold on
bplot(PIPRCombined.result, 1)
bplot(netPIPRWindowed{3}, 2)
xticks([1, 2])
xticklabels({'Session 1/2 Combined', 'Session 3'})
ylabel('PIPR: Average Blue Sustained Constriction - Average Red Sustained Constriction')
saveas(plotFig, fullfile(outDir, '6_PIPRbySession_window.pdf'), 'pdf')

% Figure 7: how PIPR relates to mel via SS
for session = 1:3
    plotFig = figure;
    title (['Session ' num2str(session')])
    prettyScatterplots(netPIPRTotalAreaNormed{session}, TPUPParameters{session}.MeltoLMS.totalResponseArea,  'xLabel', 'Net PIPR (Blue-Red)/(Blue+Red)', 'yLabel', 'Mel/LMS Total Response Area', 'significance', 'rho')
    saveas(plotFig, fullfile(outDir, ['7_PIPRxSS_session', num2str(session), '.pdf']), 'pdf')
end

% Figure 8: Reproducibility of average responses from session 1/2 combined
% at the group level compared with session 3
% first make the session 1/2 group average response
for stimulus = 1:length(stimuli)
    for tt = 1:length(timebase)
        [combinedResultAtTimepoint] = combineResultAcrossSessions(goodSubjects, averageResponsePerSubject{1}.(stimuli{stimulus})(:, tt), averageResponsePerSubject{2}.(stimuli{stimulus})(:, tt));
        combinedGroupAverageResponse.(stimuli{stimulus})(tt) = nanmean(combinedResultAtTimepoint.result);
    end
end

plotFig = figure;
for stimulus = 1:length(stimuli)
    subplot(2,2,stimulus)
    
    timebase = 0:20:13980;
    
    plot(timebase, combinedGroupAverageResponse.(stimuli{stimulus})*100, '-.', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 3)
    hold on
    plot(timebase, groupAverageResponse{3}.(stimuli{stimulus})*100, 'Color', 'b')
    
    % now adjust the plot a bit
    if stimulus == 1
        legend('Session 1/2 Combined', 'Session 3', 'Location', 'SouthEast')
    end
    xlabel('Time (ms)')
    ylabel('Pupil Diameter (% Change)')
    ylim([-50 10])
    xlim([0 14000])
    title([stimuli{stimulus}])
    
end
suptitle('Reproducibility of group average response at higher light levels')
set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['8_groupAverageResponseReproducibility_12x3.pdf']), 'pdf');
close(plotFig)

% Figure 9: is overall repsonsiveness reproducible from session 1/2 to
% session 3?
[ overallPupilResponsiveness ] = calculateOverallPupilResponsiveness(goodSubjects, totalResponseArea, dropboxAnalysisDir);
[ combinedOverallResponsiveness ]  = combineResultAcrossSessions(goodSubjects, overallPupilResponsiveness{1}, overallPupilResponsiveness{2});
pairResultAcrossSessions(combinedOverallResponsiveness.subjectKey, goodSubjects{3}.ID, combinedOverallResponsiveness.result, overallPupilResponsiveness{3}, dropboxAnalysisDir, 'xLims', [-225 0], 'yLims', [-225 0], 'subdir', 'figures', 'saveName', '9_overallResponsiveness_12x3', 'xLabel', 'Overall Responsiveness Session 1/2', 'yLabel', 'Overall Responsiveness Session 3')

% Figure 10: is the total response area for a given stimulus reproducible from session 1/2 to session 3?

plotFig = figure;
for stimulus = 1:length(stimuli)
    subplot(2,2,stimulus)
    [ combinedTotalResponseArea.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.(stimuli{stimulus}), totalResponseArea{2}.(stimuli{stimulus}));
    pairResultAcrossSessions(combinedTotalResponseArea.(stimuli{stimulus}).subjectKey, goodSubjects{3}.ID, combinedTotalResponseArea.(stimuli{stimulus}).result, totalResponseArea{3}.(stimuli{stimulus}), dropboxAnalysisDir, 'xLims', [-375 0], 'yLims', [-375 0], 'subdir', 'figures', 'xLabel', [stimuli{stimulus}, ' Session 1/2 Total Response Area'], 'yLabel', [stimuli{stimulus}, ' Session 3 Total Response Area'])
end
suptitle('Reproducibility of Total Response Area for Each Stimulus')
saveas(plotFig, fullfile(outDir, '10_reproducibilityByStimulus_12x3.pdf'), 'pdf')

lims = {-200, -200, -375, -375};
for stimulus = 1:length(stimuli)
    plotFig = figure;
    [ combinedTotalResponseArea.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).totalResponseArea, TPUPParameters{2}.(stimuli{stimulus}).totalResponseArea);
    [ combinedTotalResponseArea_lowerBound.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{1})]), TPUPParameters{2}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{1})]));
    [ combinedTotalResponseArea_upperBound.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, TPUPParameters{1}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{2})]), TPUPParameters{2}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{2})]));
    
    session12error = [];
    session12error(1,:) = combinedTotalResponseArea.(stimuli{stimulus}).result - combinedTotalResponseArea_lowerBound.(stimuli{stimulus}).result;
    session12error(2,:) = combinedTotalResponseArea_upperBound.(stimuli{stimulus}).result - combinedTotalResponseArea.(stimuli{stimulus}).result;
    
    session3error = [];
    session3error(1,:) = TPUPParameters{3}.(stimuli{stimulus}).totalResponseArea - TPUPParameters{3}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{1})]);
    session3error(2,:) = TPUPParameters{3}.(stimuli{stimulus}).(['totalResponseArea_', num2str(confidenceInterval{2})]) - TPUPParameters{3}.(stimuli{stimulus}).totalResponseArea;
    
    
    pairResultAcrossSessions(combinedTotalResponseArea.(stimuli{stimulus}).subjectKey, goodSubjects{3}.ID, combinedTotalResponseArea.(stimuli{stimulus}).result, TPUPParameters{3}.(stimuli{stimulus}).totalResponseArea, dropboxAnalysisDir, 'xLims', [lims{stimulus} 0], 'yLims', [lims{stimulus} 0], 'sessionOneErrorBar', session12error, 'sessionTwoErrorBar', session3error, 'subdir', 'figures', 'xLabel', [stimuli{stimulus}, ' Session 1/2 Total Response Area'], 'yLabel', [stimuli{stimulus}, ' Session 3 Total Response Area'])
    title(['Reproducibility of ' stimuli{stimulus}, ' Total Response Area from Session 1/2 to Session 3'])
    saveas(plotFig, fullfile(outDir, ['10_' stimuli{stimulus}, 'Reproducibility_12x3.pdf']), 'pdf')
    close(plotFig)
end

%% The mel/lms response ratio is not reproducibile between sessions 1/2 combined and session 3 at higher light levels
% Ultimatley we think the explanation for this observation is that the
% melanopsin responses, or at least our fits to these responses, are
% associated with larger error. Here is a summary figure that looks at how
% the width of the 90% confidence interval compares for melanopsin and
% cones

% first just looking at the width of the 90% confidence interval for all
% sessions
confidenceIntervalWidth = [];
plotFig = figure;
for session = 1:3
    confidenceIntervalWidth.Mel(session,:) = mean(TPUPParameters{session}.Mel.totalResponseArea_90 - TPUPParameters{session}.Mel.totalResponseArea_10);
    confidenceIntervalWidth.LMS(session,:) = mean(TPUPParameters{session}.LMS.totalResponseArea_90 - TPUPParameters{session}.LMS.totalResponseArea_10);
    confidenceIntervalWidth.Blue(session,:) = mean(TPUPParameters{session}.Blue.totalResponseArea_90 - TPUPParameters{session}.Blue.totalResponseArea_10);
    confidenceIntervalWidth.Red(session,:) = mean(TPUPParameters{session}.Red.totalResponseArea_90 - TPUPParameters{session}.Red.totalResponseArea_10);
end

b = bar(horzcat(confidenceIntervalWidth.Mel, confidenceIntervalWidth.LMS, confidenceIntervalWidth.Blue, confidenceIntervalWidth.Red));
b(1).FaceColor = 'c';
b(2).FaceColor = 'k';
b(3).FaceColor = 'b';
b(4).FaceColor = 'r';
legend('Mel', 'LMS', 'Blue', 'Red')
ylabel('90% Confidence Interval Width, Raw Values')
xlabel('Session')
saveas(plotFig, fullfile(outDir, ['11_confidenceIntervalWidth_rawValues.pdf']), 'pdf')

% first just looking at the width of the 90% confidence interval for all
% sessions, but now normalizing 90% confidence interval width for
% differences in size of response
confidenceIntervalWidth = [];
plotFig = figure;
for session = 1:3
    confidenceIntervalWidth.Mel(session,:) = mean(-(TPUPParameters{session}.Mel.totalResponseArea_90./TPUPParameters{session}.Mel.totalResponseArea - TPUPParameters{session}.Mel.totalResponseArea_10./TPUPParameters{session}.Mel.totalResponseArea));
    confidenceIntervalWidth.LMS(session,:) = mean(-(TPUPParameters{session}.LMS.totalResponseArea_90./TPUPParameters{session}.LMS.totalResponseArea - TPUPParameters{session}.LMS.totalResponseArea_10./TPUPParameters{session}.LMS.totalResponseArea));
    confidenceIntervalWidth.Blue(session,:) = mean(-(TPUPParameters{session}.Blue.totalResponseArea_90./TPUPParameters{session}.Blue.totalResponseArea - TPUPParameters{session}.Blue.totalResponseArea_10./TPUPParameters{session}.Blue.totalResponseArea));
    confidenceIntervalWidth.Red(session,:) = mean(-(TPUPParameters{session}.Red.totalResponseArea_90./TPUPParameters{session}.Red.totalResponseArea - TPUPParameters{session}.Red.totalResponseArea_10./TPUPParameters{session}.Red.totalResponseArea));
    
end

b = bar(horzcat(confidenceIntervalWidth.Mel, confidenceIntervalWidth.LMS, confidenceIntervalWidth.Blue, confidenceIntervalWidth.Red));
b(1).FaceColor = 'c';
b(2).FaceColor = 'k';
b(3).FaceColor = 'b';
b(4).FaceColor = 'r';
legend('Mel', 'LMS', 'Blue', 'Red')
ylabel('90% Confidence Interval Width, %')
xlabel('Session')
saveas(plotFig, fullfile(outDir, ['11_confidenceIntervalWidth_percent.pdf']), 'pdf')





end % end function