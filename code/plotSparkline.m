function plotSparkline(averageBlueCombined, averageLMSCombined, averageMelCombined, averageRedCombined, semBlue, semLMS, semMel, semRed, dropboxAnalysisDir)

stimulusOrder = {'LMS' 'Mel' 'Blue' 'Red'};


plotFig = figure;
%set(plotFig, 'units', 'normalized', 'Position', [0.1300 0.1100 0.7750 10.8150])



for ss = 1:size(averageBlueCombined{1},1)
    for stimulus = 1:length(stimulusOrder)
        if stimulus == 1 % LMS
            response = averageLMSCombined;
            error = semLMS;
        elseif stimulus == 2 % mel
            response = averageMelCombined;
            error = semMel;
        elseif stimulus == 3 % blue
            response = averageBlueCombined;
            error = semBlue;
        elseif stimulus == 4 % red
            response = averageRedCombined;
            error = semRed;
        end
        subplotHandle = subplot(size(averageBlueCombined{1},1), length(stimulusOrder), ((ss-1)*4 + stimulus));
        hold on
        shadedErrorBar(((1:length(response{1}(ss,:)))*0.02),response{1}(ss,:)*100, error{1}(ss,:)*100, 'k', 1);
        if ss <= size(averageBlueCombined{2},1)
            shadedErrorBar(((1:length(response{2}(ss,:)))*0.02),response{2}(ss,:)*100, error{2}(ss,:)*100, 'b', 1);
        end
        if ss == 1
            title(stimulusOrder{stimulus})
        end
        
        
        ylim([-60 20])
        xlim([0 14])
        if stimulus == 1
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
        else
            set(subplotHandle, 'visible', 'off')
            
        end
        if ss == 1
            title(stimulusOrder{stimulus})
        end
        
    end
end

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/sparkLine');

if ~exist(outDir, 'dir')
            mkdir(outDir);
        end



saveas(plotFig, fullfile(outDir, ['sparkLine.pdf']), 'pdf');
close(plotFig);

end
