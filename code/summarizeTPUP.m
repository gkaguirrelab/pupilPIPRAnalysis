function summarizeTPUP(TPUPAmplitudes, temporalParameters, varianceExplained, dropboxAnalysisDir)

%% make a bar graph to compare relative contributions of each parameter to the final fit
stimulusOrder = {'LMS' 'mel' 'blue' 'red'};

for session = 1:2
    amplitudes = [];
    sem = [];
    for stimulus = 1:length(stimulusOrder)
        for measure = 1:3 % we have three measures of amplitude: transient, sustained, persistent as well as three temporal parameters
            amplitudes(measure,stimulus) = mean(TPUPAmplitudes{session}{stimulus}(:,measure));
            sem(measure,stimulus) = std(TPUPAmplitudes{session}{stimulus}(:,measure))/sqrt(length(TPUPAmplitudes{session}{stimulus}));
            meanTemporalParameters(measure,stimulus) = mean(temporalParameters{session}{stimulus}(:,measure));
            semTemporalParameters(measure,stimulus) = std(temporalParameters{session}{stimulus}(:,measure))/sqrt(length(temporalParameters{session}{stimulus}));
            
        end
    end
    
    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/summarizeTPUP', num2str(session));
    
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    plotFig = figure;
    
    b = barwitherr(sem, amplitudes);
    b(1).FaceColor = 'c';
    b(2).FaceColor = 'm';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Transient', 'Sustained', 'Persistent'})
    title('Mean TPUP Amplitudes')
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_amplitudes.png']), 'png');
    close(plotFig);
    
    
    % now compare the temporal parameters
    % first set the delay to positive
    for stimulus = 1:length(stimulusOrder)
        meanTemporalParameters(1,stimulus) = meanTemporalParameters(1,stimulus) * -1;
    end
    
    plotFig = figure;
    b = barwitherr(semTemporalParameters, meanTemporalParameters);
    b(1).FaceColor = 'c';
    b(2).FaceColor = 'm';
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
        medianVarianceExplained(1,stimulus) = median(varianceExplained{session}{stimulus}(:,1));
        iqrVarianceExplained(1,stimulus) = iqr(varianceExplained{session}{stimulus}(:,1));
    end
    % now do the plotting
    plotFig = figure;
    b = barwitherr(1/2*iqrVarianceExplained, medianVarianceExplained);
    
    set(gca,'XTickLabel',{'LMS', 'Mel', 'Blue', 'Red'})
    %legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    title('Median Variance Explained')
    saveas(plotFig, fullfile(outDir, ['compareStimuli_medianVarianceExplained.png']), 'png');
    close(plotFig);
end