function summarizeTPUP(TPUPParameters, dropboxAnalysisDir)

%% make a bar graph to compare relative contributions of each parameter to the final fit
stimulusOrder = {'LMS' 'Mel' 'Blue' 'Red'};

for session = 1:3
    
    %% first compare mean values of each parameter across different
    % stimulation conditions
    amplitudes = [];
    sem = [];
    for stimulus = 1:length(stimulusOrder)
        
        measures = {'transientAmplitude', 'sustainedAmplitude', 'persistentAmplitude'};
        temporalMeasures = {'delay', 'gammaTau', 'exponentialTau'};
        for measure = 1:3 % we have three measures of amplitude: transient, sustained, persistent as well as three temporal parameters
            amplitudes(measure,stimulus) = mean(TPUPParameters{session}.(stimulusOrder{stimulus}).(measures{measure}));
            sem(measure,stimulus) = std(TPUPParameters{session}.(stimulusOrder{stimulus}).(measures{measure}))/sqrt(length(TPUPParameters{session}.(stimulusOrder{stimulus}).(measures{measure})));
            meanTemporalParameters(measure,stimulus) = mean(TPUPParameters{session}.(stimulusOrder{stimulus}).(temporalMeasures{measure}));
            semTemporalParameters(measure,stimulus) = std(TPUPParameters{session}.(stimulusOrder{stimulus}).(temporalMeasures{measure}))/sqrt(length(TPUPParameters{session}.(stimulusOrder{stimulus}).(temporalMeasures{measure})));
            
        end
    end
    
    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/summarizeTPUP', num2str(session));
    
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    plotFig = figure;
    
    b = barwitherr(sem, amplitudes);
    b(1).FaceColor = 'k';
    b(2).FaceColor = 'c';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Transient', 'Sustained', 'Persistent'})
    title('Mean TPUP Amplitudes')
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_amplitudes.png']), 'png');
    close(plotFig);
    
    % now for median values
    amplitudes = [];
    sem = [];
    iqrAmplitudes = [];
    for stimulus = 1:length(stimulusOrder)
        measures = {'transientAmplitude', 'sustainedAmplitude', 'persistentAmplitude'};
        temporalMeasures = {'delay', 'gammaTau', 'exponentialTau'};
        for measure = 1:3 % we have three measures of amplitude: transient, sustained, persistent as well as three temporal parameters
            amplitudes(measure,stimulus) = median(TPUPParameters{session}.(stimulusOrder{stimulus}).(measures{measure}));
            iqrAmplitudes(measure,stimulus) = iqr(TPUPParameters{session}.(stimulusOrder{stimulus}).(measures{measure}));
            meanTemporalParameters(measure,stimulus) = mean(TPUPParameters{session}.(stimulusOrder{stimulus}).(temporalMeasures{measure}));
            semTemporalParameters(measure,stimulus) = std(TPUPParameters{session}.(stimulusOrder{stimulus}).(temporalMeasures{measure}))/sqrt(length(TPUPParameters{session}.(stimulusOrder{stimulus}).(temporalMeasures{measure})));
            
        end
    end
    
    
    
    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/summarizeTPUP', num2str(session));
    
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    plotFig = figure;
    
    b = barwitherr(1/2*iqrAmplitudes, amplitudes);
    b(1).FaceColor = 'k';
    b(2).FaceColor = 'c';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Transient', 'Sustained', 'Persistent'})
    title('Median TPUP Amplitudes')
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_amplitudes_median.png']), 'png');
    close(plotFig);
    
    % box and whisker plot for amplitude parameters
    for stimuli = 1:length(stimulusOrder)
        plotFig = figure;
        hold on
        bplot(TPUPParameters{session}.(stimulusOrder{stimuli}).transientAmplitude, 1, 'color', 'c')
        bplot(TPUPParameters{session}.(stimulusOrder{stimuli}).sustainedAmplitude, 2, 'color', 'c')
        bplot(TPUPParameters{session}.(stimulusOrder{stimuli}).persistentAmplitude, 3, 'color', 'c')
        xticks([1, 2, 3])
        xticklabels({'Transient', 'Sustained', 'Persistent'})
        saveas(plotFig, fullfile(outDir, [stimulusOrder{stimuli}, '_bplot.png']), 'png');
        close(plotFig)
    end
    
    % make a combined one for mel and lms
    plotFig = figure;
    hold on
    bplot(TPUPParameters{session}.Mel.transientAmplitude, 1, 'color', 'c')
    bplot(TPUPParameters{session}.Mel.sustainedAmplitude, 4, 'color', 'c')
    bplot(TPUPParameters{session}.Mel.persistentAmplitude, 7, 'color', 'c')
    bplot(TPUPParameters{session}.LMS.transientAmplitude, 2, 'color', 'm')
    bplot(TPUPParameters{session}.LMS.sustainedAmplitude, 5, 'color', 'm')
    bplot(TPUPParameters{session}.LMS.persistentAmplitude, 8, 'color', 'm')
    xticks([1.5, 4.5, 7.5])
    xticklabels({'Transient', 'Sustained', 'Persistent'})
    saveas(plotFig, fullfile(outDir, ['MelLMSComparison_bplot.png']), 'png');
        close(plotFig)
    
    % now compare the temporal parameters
    % first set the delay to positive
    for stimulus = 1:length(stimulusOrder)
        meanTemporalParameters(1,stimulus) = meanTemporalParameters(1,stimulus) * -1;
    end
    
    plotFig = figure;
    b = barwitherr(semTemporalParameters, meanTemporalParameters);
    b(1).FaceColor = 'k';
    b(2).FaceColor = 'c';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Delay', 'Gamma Tau', 'Exponential Tau'})
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthEast')
    title('Mean Temporal Parameters')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_temporalParameters.png']), 'png');
    close(plotFig);
    
    % now compare the median variance explained
    % first calculate the median variance for each stimulation
    for stimulus = 1:length(stimulusOrder)
        medianVarianceExplained(1,stimulus) = median((TPUPParameters{session}.(stimulusOrder{stimulus}).rSquared));
        iqrVarianceExplained(1,stimulus) = iqr(TPUPParameters{session}.(stimulusOrder{stimulus}).rSquared);
    end
    % now do the plotting
    plotFig = figure;
    b = barwitherr(1/2*iqrVarianceExplained, medianVarianceExplained);
    
    set(gca,'XTickLabel',{'LMS', 'Mel', 'Blue', 'Red'})
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    title('Median Variance Explained')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_medianVarianceExplained.png']), 'png');
    close(plotFig);
    
    %% show distribution of different parameters for each stimulation
    
    
    %     binWidth = 10;
    %     h1 = histogram(TPUPAmplitudes{1}{1}(:,1), 'BinWidth', binWidth, 'FaceColor', 'c', 'FaceAlpha', 0.1)
    %     h2 = histogram(TPUPAmplitudes{1}{2}(:,1), 'BinWidth', binWidth, 'FaceColor', 'm', 'FaceAlpha', 0.1)
    %     h3 = histogram(TPUPAmplitudes{1}{3}(:,1), 'BinWidth', binWidth, 'FaceColor', 'b', 'FaceAlpha', 0.1)
    %     h3 = histogram(TPUPAmplitudes{1}{4}(:,1), 'BinWidth', binWidth, 'FaceColor', 'r', 'FaceAlpha', 0.1)
    %     legend('LMS', 'Mel', 'Blue', 'Red')
    
    plotFig = figure;
    set(plotFig, 'units', 'normalized', 'Position', [0.1300 0.1100 0.7750 0.8150])
    
    
    stimulusOrder = {'LMS' 'Mel' 'Blue' 'Red'};
    stimulusColor = {'k' 'c' 'b' 'r'};
    
    % Transient Amplitude
    subplot(2,3,1)
    hold on
    edges = -70:10:0;
    edgeMidpoint = (edges(1) + (edges(2) - edges(1))/2):(edges(2) - edges(1)):edges(length(edges)) - (edges(2) - edges(1))/2;
    
    for stimulation = 1:length(stimulusOrder)
        h = histc(TPUPParameters{session}.(stimulusOrder{stimulation}).transientAmplitude, edges);
        binNumber = length(h);
        h(binNumber-1) = h(binNumber-1)+h(binNumber);
        h(binNumber) = [];
        plotVariable{stimulation} = plot(edgeMidpoint, h, 'Color', stimulusColor{stimulation});
        hold on
        plot(edgeMidpoint, h, 'o', 'Color', stimulusColor{stimulation})

    end
    legend([plotVariable{1} plotVariable{2} plotVariable{3} plotVariable{4}], 'LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthWest')
    title('Transient Amplitude')
    ax = gca;
    ylabel('Frequency')
    
    for xx = 1:length(edges)
        line([edges(xx) edges(xx)], [ax.YLim(1) ax.YLim(2)],  'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.1)
    end
    ax.XTick = edges;
    
    xlim([-70 0])
    
    
    % Sustained Amplitude
    subplot(2,3,2)
    hold on
    edges = -100:10:0;
    edgeMidpoint = (edges(1) + (edges(2) - edges(1))/2):(edges(2) - edges(1)):edges(length(edges)) - (edges(2) - edges(1))/2;
    
    for stimulation = 1:length(stimulusOrder)
        h = histc((TPUPParameters{session}.(stimulusOrder{stimulation}).sustainedAmplitude), edges);
        binNumber = length(h);
        h(binNumber-1) = h(binNumber-1)+h(binNumber);
        h(binNumber) = [];
        plot(edgeMidpoint, h, 'Color', stimulusColor{stimulation})
        hold on
        plot(edgeMidpoint, h, 'o', 'Color', stimulusColor{stimulation})
    end
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthWest')
    title('Sustained Amplitude')
    ax = gca;
        ylabel('Frequency')

    
    for xx = 1:length(edges)
        line([edges(xx) edges(xx)], [ax.YLim(1) ax.YLim(2)],  'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.1)
    end
    ax.XTick = edges;
    
    % Persistent Amplitude
    subplot(2,3,3)
    hold on
    edges = -300:50:0;
    edgeMidpoint = (edges(1) + (edges(2) - edges(1))/2):(edges(2) - edges(1)):edges(length(edges)) - (edges(2) - edges(1))/2;
    
    for stimulation = 1:length(stimulusOrder)
        h = histc((TPUPParameters{session}.(stimulusOrder{stimulation}).persistentAmplitude), edges);
        binNumber = length(h);
        h(binNumber-1) = h(binNumber-1)+h(binNumber);
        h(binNumber) = [];
        plot(edgeMidpoint, h, 'Color', stimulusColor{stimulation})
        hold on
        plot(edgeMidpoint, h, 'o', 'Color', stimulusColor{stimulation})
    end
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthWest')
    title('Persistent Amplitude')
    ax = gca;
        ylabel('Frequency')

    
    for xx = 1:length(edges)
        line([edges(xx) edges(xx)], [ax.YLim(1) ax.YLim(2)],  'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.1)
    end
    ax.XTick = edges;
    
    % Delay
    subplot(2,3,4)
    hold on
    edges = -500:50:0;
    edgeMidpoint = (edges(1) + (edges(2) - edges(1))/2):(edges(2) - edges(1)):edges(length(edges)) - (edges(2) - edges(1))/2;
    
    for stimulation = 1:length(stimulusOrder)
        h = histc((TPUPParameters{session}.(stimulusOrder{stimulation}).delay), edges);
        binNumber = length(h);
        h(binNumber-1) = h(binNumber-1)+h(binNumber);
        h(binNumber) = [];
        plot(edgeMidpoint, h, 'Color', stimulusColor{stimulation})
        hold on
        plot(edgeMidpoint, h, 'o', 'Color', stimulusColor{stimulation})
    end
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthWest')
    title('Delay')
    xlim([-500 0])
    ax = gca;
        ylabel('Frequency')

    
    for xx = 1:length(edges)
        line([edges(xx) edges(xx)], [ax.YLim(1) ax.YLim(2)],  'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.1)
    end
    ax.XTick = edges;
    
    % Gamma
    subplot(2,3,5)
    hold on
    edges = 100:100:800;
    edgeMidpoint = (edges(1) + (edges(2) - edges(1))/2):(edges(2) - edges(1)):edges(length(edges)) - (edges(2) - edges(1))/2;
    
    for stimulation = 1:length(stimulusOrder)
        h = histc((TPUPParameters{session}.(stimulusOrder{stimulation}).gammaTau), edges);
        binNumber = length(h);
        h(binNumber-1) = h(binNumber-1)+h(binNumber);
        h(binNumber) = [];
        plot(edgeMidpoint, h, 'Color', stimulusColor{stimulation})
        hold on
        plot(edgeMidpoint, h, 'o', 'Color', stimulusColor{stimulation})
    end
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthWest')
    title('Gamma Tau')
    xlim([100 800])
    ax = gca;
        ylabel('Frequency')

    
    for xx = 1:length(edges)
        line([edges(xx) edges(xx)], [ax.YLim(1) ax.YLim(2)],  'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.1)
    end
    ax.XTick = edges;
    
    % Exponential
    subplot(2,3,6)
    hold on
    edges = 0:5:50;
    edgeMidpoint = (edges(1) + (edges(2) - edges(1))/2):(edges(2) - edges(1)):edges(length(edges)) - (edges(2) - edges(1))/2;
    
    for stimulation = 1:length(stimulusOrder)
        h = histc((TPUPParameters{session}.(stimulusOrder{stimulation}).exponentialTau), edges);
        binNumber = length(h);
        h(binNumber-1) = h(binNumber-1)+h(binNumber);
        h(binNumber) = [];
        plot(edgeMidpoint, h, 'Color', stimulusColor{stimulation})
        hold on
        plot(edgeMidpoint, h, 'o', 'Color', stimulusColor{stimulation})
    end
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthWest')
    title('Exponential Tau')
    xlim([0 50])
    ax = gca;
        ylabel('Frequency')

    
    for xx = 1:length(edges)
        line([edges(xx) edges(xx)], [ax.YLim(1) ax.YLim(2)],  'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 0.1)
    end
    ax.XTick = edges;
    saveas(plotFig, fullfile(outDir, ['parameterDistribution.png']), 'png');
    close(plotFig);
    
    %% Look at percent persistent as a function of stimulation
    % we've seen that both the transient and sustained amplitudes are
    % reduced for melanopsin stimulation relative to LMS. Express this
    % quantiatively where percent persistent = (peristent
    % )/(sustained + transient + persisent) * 100%
    for ss = 1:length(TPUPParameters{session}.LMS.transientAmplitude)
        for stimulation = 1:length(stimulusOrder)
            
            percentPersistent{session}(ss, stimulation) = (TPUPParameters{session}.(stimulusOrder{stimulation}).persistentAmplitude(ss))/(TPUPParameters{session}.(stimulusOrder{stimulation}).transientAmplitude(ss) + TPUPParameters{session}.(stimulusOrder{stimulation}).sustainedAmplitude(ss) + TPUPParameters{session}.(stimulusOrder{stimulation}).persistentAmplitude(ss)) * 100;
        end
    end
    
    for stimulation = 1:length(stimulusOrder)
        meanPercentPersistent{session}(stimulation) = nanmean(percentPersistent{session}(:, stimulation));
        semPercentPersistent{session}(stimulation) = nanstd((percentPersistent{session}(:, stimulation)))/sqrt(length((percentPersistent{session}(:, stimulation))));
    end
    plotFig = figure;
    b = barwitherr(semPercentPersistent{session}, meanPercentPersistent{session});
    set(gca,'XTickLabel',{'LMS', 'Mel', 'Blue', 'Red'})
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    title('Mean Percent Persistent = P/(T+S+P)')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_meanPercentPersistent1.png']), 'png');
    close(plotFig);
    
    plotFig = figure;
    data = horzcat({percentPersistent{session}(:,1)', percentPersistent{session}(:,2)', percentPersistent{session}(:,3)', percentPersistent{session}(:,4)'});
    [test] = plotSpread(data, 'distributionMarkers', 'o', 'xNames', {'LMS', 'Mel', 'Blue', 'Red'});
    saveas(plotFig, fullfile(outDir, ['compareStimuli_meanPercentPersistent1_distribution.png']), 'png');
    close(plotFig);
    
    % but also calculate percent persistent by just normalizing by the
    % sustained and persistent components, with the logic being that the
    % transient component is a simple "alerting" response to the stimulus
    for ss = 1:length(TPUPParameters{session}.LMS.transientAmplitude)
        for stimulation = 1:length(stimulusOrder)
            
            percentPersistent{session}(ss, stimulation) = TPUPParameters{session}.(stimulusOrder{stimulation}).persistentAmplitude(ss)/(TPUPParameters{session}.(stimulusOrder{stimulation}).sustainedAmplitude(ss) + TPUPParameters{session}.(stimulusOrder{stimulation}).persistentAmplitude(ss)) * 100;
        end
    end
    
    for stimulation = 1:length(stimulusOrder)
        meanPercentPersistent{session}(stimulation) = nanmean(percentPersistent{session}(:, stimulation));
        semPercentPersistent{session}(stimulation) = nanstd((percentPersistent{session}(:, stimulation)))/sqrt(length((percentPersistent{session}(:, stimulation))));
    end
    plotFig = figure;
    b = barwitherr(semPercentPersistent{session}, meanPercentPersistent{session});
    set(gca,'XTickLabel',{'LMS', 'Mel', 'Blue', 'Red'})
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    title('Mean Percent Persistent = P/(S+P)')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_meanPercentPersistent2.png']), 'png');
    close(plotFig);
    
    plotFig = figure;
    data = horzcat({percentPersistent{session}(:,1)', percentPersistent{session}(:,2)', percentPersistent{session}(:,3)', percentPersistent{session}(:,4)'});
    [test] = plotSpread(data, 'distributionMarkers', 'o', 'xNames', {'LMS', 'Mel', 'Blue', 'Red'});
    saveas(plotFig, fullfile(outDir, ['compareStimuli_meanPercentPersistent2_distribution.png']), 'png');
    close(plotFig);
    
end

end % end function