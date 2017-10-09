function figures(goodSubjects, averageResponsePerSubject, groupAverageResponse, amplitudesPerSubject, TPUPAmplitudes, temporalParameters, dropboxAnalysisDir)

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
outDir = fullfile('~/Desktop/pupilPIPRAnalysis/figures');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Figure 1

%% Figure 2

% a. group average responses for each stimulus type for each session


stimuli = {'LMS' 'Mel' 'Blue' 'Red'};
plotFig = figure;


for stimulus = 1:length(stimulusOrder)
    subplot(2,2,stimulus)
    
    timebase = 0:20:13980;

    plot(timebase, groupAverageResponse{1}.(stimuli{stimulus}), '-.', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 3)
    hold on
    plot(timebase, groupAverageResponse{2}.(stimuli{stimulus}), 'Color', 'b')
    
    % now adjust the plot a bit
    if stimulus == 1
        legend('First Session', 'Second Session', 'Location', 'SouthEast')
    end
    xlabel('Time (ms)')
    ylabel('Pupil Diameter (% Change)')
    ylim([-0.5 0.1])
    title([stimulusOrder{stimulus}])
    ax1 = gca;
    yruler = ax1.YRuler;
    yruler.Axle.Visible = 'off';
    xruler = ax1.XRuler;
    xruler.Axle.Visible = 'off';
    set(gca, 'Ticklength', [0 0])
    grid on
end

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['2a.pdf']), 'pdf');
close(plotFig)

% b. Sparkline of individual subjects
plotSparkline(goodSubjects, averageResponsePerSubject, dropboxAnalysisDir)


%% Figure 3: overall scaling of the amplitude response
% a: people vary in overall pupil responsivness
% sessionCollapse
plotFig = figure;
hold on

subplot(1,3,1)
[ LMSAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.LMS, amplitudesPerSubject{2}.LMS);
[ melAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.Mel, amplitudesPerSubject{2}.Mel);
prettyScatterplots(LMSAmplitudes*100, melAmplitudes*100, LMSAmplitudes*0, LMSAmplitudes*0,'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'dotSize', 5, 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'LMS Amplitude (%)', 'yLabel', 'Melanopsin Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'spearman')
% change the y-ticks (without changing, it was different from this x axis
% -- this step keeps them consistent)
ax = gca;
ax.YTick = [0 20 40 60];
% also display confidence interval of the spearman rho
[ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, LMSAmplitudes*100, melAmplitudes*100);
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');
xrange = xlims(2)-xlims(1);
yrange = ylims(2) - ylims(1);
xpos = xlims(1)+0.20*xrange;
ypos = ylims(1)+0.75*yrange;
string = (sprintf(['CI = ', sprintf('%.2f', confidenceInterval(1)), ' - ', sprintf('%.2f', confidenceInterval(2))]));
text(xpos, ypos, string, 'fontsize',12)

subplot(1,3,2)
[ blueAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.Blue, amplitudesPerSubject{2}.Blue);
[ redAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.Red, amplitudesPerSubject{2}.Red);
prettyScatterplots(blueAmplitudes*100, redAmplitudes*100, 0*redAmplitudes, 0*redAmplitudes, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'dotSize', 5, 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'Blue Amplitude (%)', 'yLabel', 'Red Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'spearman')
ax = gca;
ax.YTick = [0 20 40 60];
[ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, blueAmplitudes, redAmplitudes);
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');
xrange = xlims(2)-xlims(1);
yrange = ylims(2) - ylims(1);
xpos = xlims(1)+0.20*xrange;
ypos = ylims(1)+0.75*yrange;
string = (sprintf(['CI = ', sprintf('%.2f', confidenceInterval(1)), ' - ', sprintf('%.2f', confidenceInterval(2))]));
text(xpos, ypos, string, 'fontsize',12)

subplot(1,3,3)
[ SSAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.SilentSubstitionAverage, amplitudesPerSubject{2}.SilentSubstitionAverage);
[ PIPRAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.PIPRAverage, amplitudesPerSubject{2}.PIPRAverage);
prettyScatterplots(SSAmplitudes*100, PIPRAmplitudes*100, 0*PIPRAmplitudes, 0*PIPRAmplitudes, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'dotSize', 5, 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'Mel+LMS Amplitude (%)', 'yLabel', 'Blue+Red Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'spearman')
ax = gca;
ax.YTick = [0 20 40 60];
[ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, SSAmplitudes, PIPRAmplitudes);
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');
xrange = xlims(2)-xlims(1);
yrange = ylims(2) - ylims(1);
xpos = xlims(1)+0.20*xrange;
ypos = ylims(1)+0.75*yrange;
string = (sprintf(['CI = ', sprintf('%.2f', confidenceInterval(1)), ' - ', sprintf('%.2f', confidenceInterval(2))]));
text(xpos, ypos, string, 'fontsize',12)


outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['3a.pdf']), 'pdf');
close(plotFig)

% b. we can account for overall pupil responsiveness by dividing amplitude
% of constriction to one stimulus by another within the same stimulus
% approach
% that is, we normalize the melanopsin response amplitude by the LMS
% repsonse amplitude, and the blue response amplitude by the red response
% amplitude

plotFig = figure;
hold on

[ melNormedAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.MeltoLMS, amplitudesPerSubject{2}.MeltoLMS);
[ SSAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.SilentSubstitionAverage, amplitudesPerSubject{2}.SilentSubstitionAverage);
prettyScatterplots(melNormedAmplitudes, SSAmplitudes*100, 0*SSAmplitudes, 0*SSAmplitudes, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'subplot', [1, 2, 1], 'yLim', [0 60], 'xLim', [0 1.2], 'unity', 'off', 'plotOption', 'square', 'xLabel', 'Mel/LMS Amplitude (%)', 'yLabel', 'Mel+LMS Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'spearman')
[ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, melNormedAmplitudes, SSAmplitudes);
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');
xrange = xlims(2)-xlims(1);
yrange = ylims(2) - ylims(1);
xpos = xlims(1)+0.20*xrange;
ypos = ylims(1)+0.75*yrange;
string = (sprintf(['CI = ', sprintf('%.2f', confidenceInterval(1)), ' - ', sprintf('%.2f', confidenceInterval(2))]));
text(xpos, ypos, string, 'fontsize',12)


[ blueNormedAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.BluetoRed, amplitudesPerSubject{2}.BluetoRed);
[ PIPRAmplitudes ] = combineResultAcrossSessions(goodSubjects, amplitudesPerSubject{1}.PIPRAverage, amplitudesPerSubject{2}.PIPRAverage);
prettyScatterplots(blueNormedAmplitudes, PIPRAmplitudes*100, 0*PIPRAmplitudes, 0*PIPRAmplitudes, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'subplot', [1, 2, 2], 'yLim', [0 60], 'xLim', [0.8 1.6], 'unity', 'off', 'plotOption', 'square', 'xLabel', 'Blue/Red Amplitude (%)', 'yLabel', 'Blue+Red Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'spearman')
[ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, blueNormedAmplitudes, PIPRAmplitudes);
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');
xrange = xlims(2)-xlims(1);
yrange = ylims(2) - ylims(1);
xpos = xlims(1)+0.20*xrange;
ypos = ylims(1)+0.75*yrange;
string = (sprintf(['CI = ', sprintf('%.2f', confidenceInterval(1)), ' - ', sprintf('%.2f', confidenceInterval(2))]));
text(xpos, ypos, string, 'fontsize',12)

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['3b.pdf']), 'pdf');
close(plotFig)

%% Figure 4: test-retest reliability
% a. demonstrate test-retest reliability of mel/lms ratio

% first maked paired results variable so we can compare the mel/lms ratio
% from the first session with the second session
plotFig = figure;
[pairedMeltoLMS_1x2] = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, amplitudesPerSubject{1}.MeltoLMS, amplitudesPerSubject{2}.MeltoLMS, dropboxAnalysisDir, 'subdir', 'figures',  'sessionOneErrorBar', amplitudesPerSubject{1}.MeltoLMS_SEM, 'sessionTwoErrorBar', amplitudesPerSubject{2}.MeltoLMS_SEM, 'xLims', [-0.2 1.8], 'yLims', [-0.2 1.8]);



% now add confidence interval to plot
[ confidenceInterval, meanRho, rhoCombined ] = bootstrapRho(goodSubjects, amplitudesPerSubject{1}.MeltoLMS, amplitudesPerSubject{2}.MeltoLMS, dropboxAnalysisDir);

pbaspect([1 1 1])
xlabel('Mel : Cone Session 1')
ylabel('Mel : Cone Session 2')
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');
xrange = xlims(2)-xlims(1);
yrange = ylims(2) - ylims(1);
xpos = xlims(1)+0.20*xrange;
ypos = ylims(1)+0.75*yrange;
string = (sprintf(['CI = ', sprintf('%.2f', confidenceInterval(1)), ' - ', sprintf('%.2f', confidenceInterval(2))]));
text(xpos, ypos, string, 'fontsize',12)

saveas(plotFig, fullfile(outDir, ['4a.pdf']), 'pdf');
close(plotFig)

% b. Bland-Altman plot
% another nice way to show test-retest reliability
plotBlandAltman(goodSubjects, amplitudesPerSubject{1}.MeltoLMS, amplitudesPerSubject{2}.MeltoLMS, dropboxAnalysisDir);
%% Figure 5: TPUP figure
% a. example model fit to average data
% first get the average response by averaging time series across subjects
% for each stimulus condition
for session = 1:2;
    for timepoints = 1:length(averageBlueCombined{session});
        averageBlueCollapsed{session}(1,timepoints) = nanmean(averageBlueCombined{session}(:,timepoints));
        semBlueCollapsed{session}(1,timepoints) = nanstd(averageBlueCombined{session}(:,timepoints))/sqrt(size(averageBlueCombined{session},1));
        averageRedCollapsed{session}(1,timepoints) = nanmean(averageRedCombined{session}(:,timepoints));
        semRedCollapsed{session}(1,timepoints) = nanstd(averageRedCombined{session}(:,timepoints))/sqrt(size(averageRedCombined{session},1));
        averageMelCollapsed{session}(1,timepoints) = nanmean(averageMelCombined{session}(:,timepoints));
        semMelCollapsed{session}(1,timepoints) = nanstd(averageMelCombined{session}(:,timepoints))/sqrt(size(averageMelCombined{session},1));
        averageLMSCollapsed{session}(1,timepoints) = nanmean(averageLMSCombined{session}(:,timepoints));
        semLMSCollapsed{session}(1,timepoints) = nanstd(averageLMSCombined{session}(:,timepoints))/sqrt(size(averageLMSCombined{session},1));
        
    end
end

% first make the average results. here the group average time series is
% combined across sessions
for tt = 1:size(averageBlueCombined{1},2)
    
    % combine results across sessions
    blueCombined = combineResultAcrossSessions(goodSubjects, averageBlueCombined{1}(:,tt), averageBlueCombined{2}(:,tt));
    averageBlue(tt) = averageResultAcrossSubjects(blueCombined');
    
    redCombined = combineResultAcrossSessions(goodSubjects, averageRedCombined{1}(:,tt), averageRedCombined{2}(:,tt));
    averageRed(tt) = averageResultAcrossSubjects(redCombined');
    
    LMSCombined = combineResultAcrossSessions(goodSubjects, averageLMSCombined{1}(:,tt), averageLMSCombined{2}(:,tt));
    averageLMS(tt) = averageResultAcrossSubjects(LMSCombined');
    
    melCombined = combineResultAcrossSessions(goodSubjects, averageMelCombined{1}(:,tt), averageMelCombined{2}(:,tt));
    averageMel(tt) = averageResultAcrossSubjects(melCombined');
end


% first plot the average melanopsin response with the median TPUP fit
% first create the stimulus structure
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

% set up boundaries for our fits
delayCombined = combineResultAcrossSessions(goodSubjects, temporalParameters{1}{2}(:,1), temporalParameters{2}{2}(:,1));
delayParameter = median(delayCombined);
gammaCombined = combineResultAcrossSessions(goodSubjects, temporalParameters{1}{2}(:,2), temporalParameters{2}{2}(:,2));
gammaParameter = median(gammaCombined);
exponentialCombined = combineResultAcrossSessions(goodSubjects, temporalParameters{1}{2}(:,3), temporalParameters{2}{2}(:,3));
exponentialParameter = median(exponentialCombined);
transientCombined = combineResultAcrossSessions(goodSubjects, TPUPAmplitudes{1}{2}(:,1), TPUPAmplitudes{2}{2}(:,1));
transientParameter = median(transientCombined);
sustainedCombined = combineResultAcrossSessions(goodSubjects, TPUPAmplitudes{1}{2}(:,2), TPUPAmplitudes{2}{2}(:,2));
sustainedParameter = median(sustainedCombined);
persistentCombined = combineResultAcrossSessions(goodSubjects, TPUPAmplitudes{1}{2}(:,3), TPUPAmplitudes{2}{2}(:,3));
persistentParameter = median(persistentCombined);

initialValues = [delayParameter, gammaParameter, exponentialParameter, transientParameter, sustainedParameter, persistentParameter];
vlb = [delayParameter, gammaParameter, exponentialParameter, transientParameter, sustainedParameter, persistentParameter];
vub = [delayParameter, gammaParameter, exponentialParameter, transientParameter, sustainedParameter, persistentParameter];

timebase = (0:20:13998);

% Temporal domain of the stimulus
deltaT = 20; % in msecs
totalTime = 14000; % in msecs
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

% Specify the stimulus struct.
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
thePacket.stimulus.timebase = timebase;

% now kernel needed for tpup
thePacket.kernel = [];

result = averageMel;


thePacket.response.timebase = timebase;
thePacket.response.values = result*100;

thePacket.metaData = [];

[paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo, 'initialValues', initialValues, 'vlb', vlb, 'vub',vub); % with

plotFig = figure;
subplot(1,2,1)
%shadedErrorBar((1:700)*0.02, result*100, semMel{1}(3,:)*100, 'c', 1);
hold on
p1 = plot((1:700)*0.02, result*100, 'Color', 'c');
p2 = plot((1:700)*0.02, modelResponseStruct.values, 'Color', 'k', 'DisplayName','Median Model Fit');

legend([p1, p2], 'Group Average', 'Median Model Fit');






ylim([-40 10])
xlabel('Time (s)')
ylabel('Pupil Diameter (% Change)')
pbaspect([1 1 1]);
title('Melanopsin Average Response')

    
% first plot the average melanopsin response with the median TPUP fit
% first create the stimulus structure
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

% set up boundaries for our fits
initialValues=[median([temporalParameters{1}{1}(:,1); temporalParameters{2}{1}(:,1)]), median([temporalParameters{1}{1}(:,2); temporalParameters{2}{1}(:,2)]), median([temporalParameters{1}{1}(:,3); temporalParameters{2}{1}(:,3)]), median([TPUPAmplitudes{1}{1}(:,1); TPUPAmplitudes{2}{1}(:,1)]), median([TPUPAmplitudes{1}{1}(:,2); TPUPAmplitudes{2}{1}(:,2)]), median([TPUPAmplitudes{1}{1}(:,3); TPUPAmplitudes{2}{1}(:,3)])];
vlb=[median([temporalParameters{1}{1}(:,1); temporalParameters{2}{1}(:,1)]), median([temporalParameters{1}{1}(:,2); temporalParameters{2}{1}(:,2)]), median([temporalParameters{1}{1}(:,3); temporalParameters{2}{1}(:,3)]), median([TPUPAmplitudes{1}{1}(:,1); TPUPAmplitudes{2}{1}(:,1)]), median([TPUPAmplitudes{1}{1}(:,2); TPUPAmplitudes{2}{1}(:,2)]), median([TPUPAmplitudes{1}{1}(:,3); TPUPAmplitudes{2}{1}(:,3)])];
vub=[median([temporalParameters{1}{1}(:,1); temporalParameters{2}{1}(:,1)]), median([temporalParameters{1}{1}(:,2); temporalParameters{2}{1}(:,2)]), median([temporalParameters{1}{1}(:,3); temporalParameters{2}{1}(:,3)]), median([TPUPAmplitudes{1}{1}(:,1); TPUPAmplitudes{2}{1}(:,1)]), median([TPUPAmplitudes{1}{1}(:,2); TPUPAmplitudes{2}{1}(:,2)]), median([TPUPAmplitudes{1}{1}(:,3); TPUPAmplitudes{2}{1}(:,3)])];

timebase = (0:20:13998);

% Temporal domain of the stimulus
deltaT = 20; % in msecs
totalTime = 14000; % in msecs
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

% Specify the stimulus struct.
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
thePacket.stimulus.timebase = timebase;

% now kernel needed for tpup
thePacket.kernel = [];

result = averageLMS;


thePacket.response.timebase = timebase;
thePacket.response.values = result*100;

thePacket.metaData = [];

[paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo, 'initialValues', initialValues, 'vlb', vlb, 'vub',vub); % with

subplot(1,2,2)
%p1 = shadedErrorBar((1:700)*0.02, result*100, semLMS{1}(3,:)*100, 'm', 1);
hold on

p1 = plot((1:700)*0.02, result*100, 'Color', 'm');

p2 = plot((1:700)*0.02, modelResponseStruct.values, 'Color', 'k', 'DisplayName','Median Model Fit');

legend([p1, p2], 'Group Average', 'Median Model Fit');





ylim([-40 10])
xlabel('Time (s)')
ylabel('Pupil Diameter (% Change)')
pbaspect([1 1 1]);
title('LMS Average Response')

saveas(plotFig, fullfile(outDir, ['5a.pdf']), 'pdf');
close(plotFig)
    