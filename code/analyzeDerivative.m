function [] = analyzeDerivative(averageBlueCombined, averageRedCombined, averageLMSCombined, averageMelCombined, dropboxAnalysisDir)

for session = 1:2
    plotFig = figure;
    set(plotFig, 'units', 'normalized', 'Position', [0.1300 0.1100 0.7750 0.8150])
    for timepoints = 1:length(averageBlueCombined{session});
        averageBlueCollapsed{session}(1,timepoints) = nanmean(averageBlueCombined{session}(:,timepoints));
        averageRedCollapsed{session}(1,timepoints) = nanmean(averageRedCombined{session}(:,timepoints));
        averageMelCollapsed{session}(1,timepoints) = nanmean(averageMelCombined{session}(:,timepoints));
        averageLMSCollapsed{session}(1,timepoints) = nanmean(averageLMSCombined{session}(:,timepoints));
    end
    
    timebase = (0:699)*0.02;
    
    for stimulus = 1:4
        if stimulus == 1
            pupilPacket.response.values = averageBlueCollapsed{session};
            name = 'Blue';
        elseif stimulus == 2
            pupilPacket.response.values = averageRedCollapsed{session};
            name = 'Red';
        elseif stimulus == 3
            pupilPacket.response.values = averageMelCollapsed{session};
            name = 'Mel';
        elseif stimulus == 4
            pupilPacket.response.values = averageLMSCollapsed{session};
            name = 'LMS';
        end
        
        pupilPacket.response.timebase = timebase;
        
        [derivative] = calculateDerivative(pupilPacket);
        
        
        subplot(2,4,stimulus)
        plot(pupilPacket.response.timebase, pupilPacket.response.values)
        ylabel('Pupil Diameter (% Change)')
        xlabel('Time (s)')
        title([name])
        subplot(2,4,stimulus+4)
        plot(pupilPacket.response.timebase, abs(derivative))
        ylabel('Pupil Speed')
        xlabel('Time (s)')
        
        
    end
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/derivative');
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [num2str(session), '.png']), 'png');
        close(plotFig);
end

end

