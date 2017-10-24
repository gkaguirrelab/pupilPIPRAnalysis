function makeFigures(goodSubjects, groupAverageResponse, TPUPParameters, dropboxAnalysisDir)

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
    xlim([0 14000])
    title([stimuli{stimulus}])
    
end

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['2a.pdf']), 'pdf');
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
end

% what if we look instead at response integration time (area under the
% curve normalized by amplitude)

% by session
[ totalResponseArea ] = calculateTotalResponseArea(TPUPParameters, dropboxAnalysisDir);
for session = 1:3
    plotFig = figure;
    hold on
    bplot(totalResponseArea{session}.LMS./amplitudesPerSubject{session}.LMS, 1, 'color', 'k')
    bplot(totalResponseArea{session}.Mel./amplitudesPerSubject{session}.Mel, 2, 'color', 'c')
    bplot(totalResponseArea{session}.Blue./amplitudesPerSubject{session}.Blue, 3, 'color', 'b')
    bplot(totalResponseArea{session}.Red./amplitudesPerSubject{session}.Red, 4, 'color', 'r')
    xticks([1, 2, 3, 4])
    xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
    ylabel('Response Integration Time')
    ylim([-650 -250])
    title(['Session ' num2str(session)])
end

% session 1 and 2 combined
stimuli = {'LMS', 'Mel', 'Blue', 'Red'};
for stimulus = 1:length(stimuli)
    [ combinedResponseIntegrationTime.(stimuli{stimulus}) ] = combineResultAcrossSessions(goodSubjects, totalResponseArea{1}.(stimuli{stimulus})./amplitudesPerSubject{1}.(stimuli{stimulus}), totalResponseArea{2}.(stimuli{stimulus})./amplitudesPerSubject{2}.(stimuli{stimulus}));
end
plotFig = figure;
hold on
bplot(combinedResponseIntegrationTime.LMS.result, 1, 'color', 'k')
bplot(combinedResponseIntegrationTime.Mel.result, 2, 'color', 'c')
bplot(combinedResponseIntegrationTime.Blue.result, 3, 'color', 'b')
bplot(combinedResponseIntegrationTime.Red.result, 4, 'color', 'r')
xticks([1, 2, 3, 4])
xticklabels({'LMS', 'Mel', 'Blue', 'Red'})
ylim([-650 -250])
xlabel('Stimulus')
ylabel('Response Integration Time')
title('Session 1/2 Combined')

%% Figure 3: Subjects varuy in overall pupil responsiveness

[ totalResponseArea ] = calculateTotalResponseArea(TPUPParameters, dropboxAnalysisDir);
[ overallPupilResponsiveness ] = calculateOverallPupilResponsiveness(goodSubjects, totalResponseArea, dropboxAnalysisDir);

%% Figure 4: 
