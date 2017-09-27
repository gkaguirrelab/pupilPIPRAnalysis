function [ percentPersistentPerSubject ] = calculatePercentPersistent(goodSubjects, TPUPParameters, dropboxAnalysisDir)




stimuli = {'LMS', 'Mel', 'Blue', 'Red'};

for session = 1:length(TPUPParameters)
    for stimulus = 1:length(stimuli)
        for ss = 1:length(TPUPParameters{session}.(stimuli{stimulus}).delay)
            percentPersistent = TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss)/(TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude(ss) + TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude(ss) + TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss));
            percentPersistentPerSubject{session}.(stimuli{stimulus})(ss) = percentPersistent;
        end
    end
end

%% Look for relationships between percent persistent across stimuli

for session = 1:length(TPUPParameters)
    
    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/percentPersistent/acrossStimulusCorrelations', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Blue, percentPersistentPerSubject{session}.Red, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Blue')
    ylabel('Red')
    saveas(plotFig, fullfile(outDir, ['blue_X_red.png']), 'png');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.LMS, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Mel')
    ylabel('LMS')
    saveas(plotFig, fullfile(outDir, ['mel_X_LMS.png']), 'png');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Mel')
    ylabel('Blue')
    saveas(plotFig, fullfile(outDir, ['mel_X_blue.png']), 'png');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.Red, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Mel')
    ylabel('Red')
    saveas(plotFig, fullfile(outDir, ['mel_X_red.png']), 'png');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.LMS, percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('LMS')
    ylabel('Blue')
    saveas(plotFig, fullfile(outDir, ['LMS_X_blue.png']), 'png');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.LMS, percentPersistentPerSubject{session}.Red, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('LMS')
    ylabel('Red')
    saveas(plotFig, fullfile(outDir, ['LMS_X_red.png']), 'png');
    close(plotFig)
end

%% Look for test re-test reliability of the measures
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/percentPersistent/testRetest');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

for stimulus = 1:length(stimuli)
    plotFig = figure;
    [percentPersistentPaired] = pairResultAcrossSessions(goodSubjects, percentPersistentPerSubject{1}.(stimuli{stimulus}), percentPersistentPerSubject{2}.(stimuli{stimulus}));
    prettyScatterplots(percentPersistentPaired.sessionOne, percentPersistentPaired.sessionTwo, 0*percentPersistentPaired.sessionOne, 0*percentPersistentPaired.sessionOne, 'significance', 'rho')
    title(stimuli{stimulus})
    xlabel('Session 1 Percent Persistent')
    ylabel('Session 2 Percent Persistent')
    
    saveas(plotFig, fullfile(outDir, [stimuli{stimulus}, '_testRetest.png']), 'png');
    close(plotFig)
    
end

%% do the permutation test to see the significance of this median difference between mel and lms


nSimulations = 1000000;
for session = 1:length(percentPersistentPerSubject)
    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/percentPersistent/acrossStimulusCorrelations', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    result = [];
    
    for nn = 1:nSimulations
        for ss = 1:length(percentPersistentPerSubject{session}.Mel)
            shouldWeFlipLabel = round(rand);
            
            if shouldWeFlipLabel == 1 % then flip the label for that subject
                melGroup(ss) = percentPersistentPerSubject{session}.LMS(ss);
                lmsGroup(ss) = percentPersistentPerSubject{session}.Mel(ss);
            elseif shouldWeFlipLabel == 0
                lmsGroup(ss) = percentPersistentPerSubject{session}.LMS(ss);
                melGroup(ss) = percentPersistentPerSubject{session}.Mel(ss);
            end
        end
        result = [result, median(melGroup) - median(lmsGroup)];
    end
    
    observedMedianDifference = median(percentPersistentPerSubject{session}.Mel) - median(percentPersistentPerSubject{session}.LMS);
    numberOfPermutationsLessThanObserved = result < observedMedianDifference;
    
    
    plotFig = figure;
    hold on
    histogram(result);
    ylims=get(gca,'ylim');
    xlims=get(gca,'xlim');
    line([observedMedianDifference, observedMedianDifference], [ylims(1), ylims(2)], 'Color', 'r')
    
    string = (sprintf(['Observed Median Difference = ', num2str(observedMedianDifference), '\n', num2str(sum(numberOfPermutationsLessThanObserved)/length(result)*100), '%% of simulations < Observed Median Difference']));
    
    ypos = 0.9*ylims(2);
    xpos = xlims(1)-0.1*xlims(1);
    text(xpos, ypos, string)
    saveas(plotFig, fullfile(outDir, ['permutationHistogram.png']), 'png');
    close(plotFig)
end



end % end funtion

