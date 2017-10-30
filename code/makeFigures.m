function makeFigures(goodSubjects, groupAverageResponse, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir)

%% Set up some basic variables
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end
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
plotFig = figure;
for stimulus = 1:length(stimuli)
    
    subplot(2,2,stimulus)
    hold on
    timebase = 0:20:13980; % in msec
    plot(timebase, groupAverageResponse{1}.(stimuli{stimulus})*100, 'Color', colors{stimulus})
    
    % make the TPUP fit from the median parameters
    temporalFit = tfeTPUP('verbosity','none');
    params0 = temporalFit.defaultParams;
    params0.paramMainMatrix(1) = median(TPUPParameters{1}.(stimuli{stimulus}).delay);
    params0.paramMainMatrix(2) = median(TPUPParameters{1}.(stimuli{stimulus}).gammaTau);
    params0.paramMainMatrix(3) = median(TPUPParameters{1}.(stimuli{stimulus}).exponentialTau);
    params0.paramMainMatrix(4) = median(TPUPParameters{1}.(stimuli{stimulus}).transientAmplitude);
    params0.paramMainMatrix(5) = median(TPUPParameters{1}.(stimuli{stimulus}).sustainedAmplitude);
    params0.paramMainMatrix(6) = median(TPUPParameters{1}.(stimuli{stimulus}).persistentAmplitude);
    
    
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

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['1b_groupAverageTPUPFits.pdf']), 'pdf');
close(plotFig)

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
title('Percent Persistent')
saveas(plotFig, fullfile(outDir, ['2_percentPersistent_session1-2Combined.pdf']), 'pdf')

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
    saveas(plotFig, fullfile(outDir, ['2_percentPersistent_session', num2str(session), '.pdf']), 'pdf')
    close(plotFig)
end

% what if we look instead at response integration time (area under the
% curve normalized by amplitude)

% by session
[ totalResponseArea ] = calculateTotalResponseArea(TPUPParameters, dropboxAnalysisDir);
[responseIntegrationTime] = calculateModeledResponseIntegrationTime(goodSubjects, totalResponseArea, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir);


for session = 1:3
    plotFig = figure;
    hold on
    bplot(responseIntegrationTime{session}.LMS, 1, 'color', 'k')
    bplot(responseIntegrationTime{session}.Mel, 2, 'color', 'c')
    bplot(responseIntegrationTime{session}.Blue, 3, 'color', 'b')
    bplot(responseIntegrationTime{session}.Red, 4, 'color', 'r')
    xticks([1, 2, 3, 4])
    xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
    ylabel('Response Integration Time')
    ylim([0 8])
    title(['Session ' num2str(session)])
    saveas(plotFig, fullfile(outDir, ['2_responseIntegrationTime_session', num2str(session), '.pdf']), 'pdf')
    close(plotFig)
end

% session 1 and 2 combined
stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
for stimulus = 1:length(stimuli)
    [ combinedResponseIntegrationTime.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, responseIntegrationTime{1}.(stimuli{stimulus}), responseIntegrationTime{2}.(stimuli{stimulus}));
end
plotFig = figure;
hold on
bplot(combinedResponseIntegrationTime.LMS.result, 1, 'color', 'k')
bplot(combinedResponseIntegrationTime.Mel.result, 2, 'color', 'c')
bplot(combinedResponseIntegrationTime.Blue.result, 3, 'color', 'b')
bplot(combinedResponseIntegrationTime.Red.result, 4, 'color', 'r')
xticks([1, 2, 3, 4])
xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
xlabel('Stimulus')
ylim([0 8])
ylabel('Response Integration Time')
title('Session 1/2 Combined')
saveas(plotFig, fullfile(outDir, ['2_responseIntegrationTime_session1-2Combined.pdf']), 'pdf')
close(plotFig)

%% Figure 3: Subjects varuy in overall pupil responsiveness

[ totalResponseArea ] = calculateTotalResponseArea(TPUPParameters, dropboxAnalysisDir);

plotFig = figure;

% calculate overall responsiveness
[ overallPupilResponsiveness ] = calculateOverallPupilResponsiveness(goodSubjects, totalResponseArea, dropboxAnalysisDir);
% match session 1 results to session 2 results
[ pairedOverallResponsiveness ]  = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, overallPupilResponsiveness{1}, overallPupilResponsiveness{2}, dropboxAnalysisDir, 'xLabel', 'Session 1 Average Responsiveness', 'yLabel', 'Session 2 Average Responsiveness', 'significance', 'rho', 'xLims', [-225 0], 'yLims', [-225 0], 'subdir', 'figures', 'saveName', '3_overallPupilResponsiveness_1x2');


%% Figure 4: Examining individual differences in the melanopsin and blue responses
% 4 a.: Examining the reproducibility of the mel/lms response ratio
[ pairedTotalResponseAreaNormed ] = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, totalResponseArea{1}.Mel./totalResponseArea{1}.LMS, totalResponseArea{2}.Mel./totalResponseArea{2}.LMS, dropboxAnalysisDir, 'subdir', 'figures', 'saveName', ['4a_melToLMS_1x2'], 'xLim', [0 1.6], 'yLim', [0 1.6], 'plotOption', 'square', 'xLabel', ['Session 1 Mel/LMS Total Response Area'], 'yLabel', ['Session 2 Mel/LMS Total Response Area']);

% 4 b.: how individual differences in the mel/lms response ratio relate to
% individual differences in the blue/red response ratio
[ combinedMeltoLMS ] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.Mel./totalResponseArea{1}.LMS, totalResponseArea{2}.Mel./totalResponseArea{2}.LMS);
[ combinedBluetoRed ] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.Blue./totalResponseArea{1}.Red, totalResponseArea{2}.Blue./totalResponseArea{2}.Red);

plotFig = figure;
prettyScatterplots(combinedMeltoLMS.result, combinedBluetoRed.result, 0*combinedMeltoLMS.result, 0*combinedMeltoLMS.result, 'xLim', [0 2], 'yLim', [0 2], 'unity', 'on', 'significance', 'rho', 'plotOption', 'square')
xlabel('Mel/LMS  Total Response Area')
ylabel('Blue/Red Total Response Area')
title('Session 1/2 Combined')
saveas(plotFig, fullfile(outDir, ['4b_meltoLMSxBluetoRed_session1-2Combined.pdf']), 'pdf')
close all

%% Additional Figures to highlight session 3 differences
% Figure 5: is the mel/lms response area ratio reproducible at a higher
% light level?
[ OneTwoCombined] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.Mel./totalResponseArea{1}.LMS, totalResponseArea{2}.Mel./totalResponseArea{2}.LMS);
[pairedMeltoLMS_12x3] = pairResultAcrossSessions(OneTwoCombined.subjectKey, goodSubjects{3}.ID, OneTwoCombined.result, totalResponseArea{3}.Mel./totalResponseArea{3}.LMS, dropboxAnalysisDir, 'subdir', 'figures', 'saveName', '5_melToLMS_12x3', 'xLims', [0 1.6], 'yLims', [0 1.6], 'plotOption', 'square', 'xLabel', ['Session 1/2 Combined Mel/LMS Total Response Area'], 'yLabel', ['Session 3 Mel/LMS Total Response Area']);

% Figure 6: at the higher light level, the PIPR is increased
[piprTotalAreaNormed, netPIPRTotalAreaNormed] = calculatePIPR(goodSubjects, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir, 'computeMethod', 'totalAreaNormed');
[ PIPRCombined ] = combineResultAcrossSessions(goodSubjects, netPIPRTotalAreaNormed{1}, netPIPRTotalAreaNormed{2});
plotFig = figure;
hold on
bplot(PIPRCombined.result, 1)
bplot(netPIPRTotalAmplitudeNormed{3}, 2)
xticks([1, 2])
xticklabels({'Session 1/2 Combined', 'Session 3'})
saveas(plotFig, fullfile(outDir, '6_PIPRbySession_totalResponseArea.pdf'), 'pdf')

[piprTotalWindowed, netPIPRWindowed] = calculatePIPR(goodSubjects, amplitudesPerSubject, TPUPParameters, dropboxAnalysisDir, 'computeMethod', 'window');
[ PIPRCombined ] = combineResultAcrossSessions(goodSubjects, netPIPRWindowed{1}, netPIPRWindowed{2});
plotFig = figure;
hold on
bplot(PIPRCombined.result, 1)
bplot(netPIPRWindowed{3}, 2)
xticks([1, 2])
xticklabels({'Session 1/2 Combined', 'Session 3'})
saveas(plotFig, fullfile(outDir, '6_PIPRbySession_window.pdf'), 'pdf')

% Figure 7: how PIPR relates to mel via SS
plotFig = figure;
prettyScatterplots(netPIPRTotalAreaNormed{3}, totalResponseArea{3}.Mel./totalResponseArea{3}.LMS, 0*netPIPRTotalAreaNormed{3}, 0*netPIPRTotalAreaNormed{3}, 'xLabel', 'Net PIPR (Blue-Red)/(Blue+Red)', 'yLabel', 'Mel/LMS Total Response Area', 'significance', 'rho')
saveas(plotFig, fullfile(outDir, ['7_PIPRxSS.pdf']), 'pdf')
end % end function