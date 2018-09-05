%% baseline size within block, not between trials
stimuli = {'LMS', 'Melanopsin'};

colors = {'k-o', 'c-o'};
plotFig = figure;

for stimulus = 1:length(stimuli)    
    for session = 1:3

        baselinePupilSize_withBadTrialsNormed{session}.(stimuli{stimulus}) = [];
    end
end
for stimulus = 1:length(stimuli)    
    for session = 1:3

        baselinePupilSize_withBadTrialsNormed{session}.(stimuli{stimulus}) = baselinePupilSize_withBadTrials{session}.(stimuli{stimulus})./nanmean(baselinePupilSize_withBadTrials{session}.(stimuli{stimulus})(:,1));
    end
end

errBar = [];
for stimulus = 1:2
    for session = 1:3
        if stimulus == 1
            p = session;
        else
            p = session + 4;
        end
        
        ax{counter} = subplot(2,4,p);
        counter = counter + 1;
        errBar(1,:) = nanstd(baselinePupilSize_withBadTrials{session}.(stimuli{stimulus}), [], 1)./sqrt((length(baselinePupilSize_withBadTrials{session}.(stimuli{stimulus})(:,1))));
        errBar(2,:) = nanstd(baselinePupilSize_withBadTrials{session}.(stimuli{stimulus}), [], 1)./sqrt((length(baselinePupilSize_withBadTrials{session}.(stimuli{stimulus})(:,1))));
        shadedErrorBar(1:24, nanmean(baselinePupilSize_withBadTrials{session}.(stimuli{stimulus}), 1), errBar, 'LineProps', colors{stimulus});
        
        %plot(nanmean(baselinePupilSize_withBadTrials.LMS,1), 'o')
        xlabel('Trial Number Within Block')
        ylabel('Baseline Pupil Diameter (mm)')
        xlim([0.9 24.1])
        ylim([0 6])
        title(['Session ' num2str(session)])
        %suptitle(stimuli{stimulus})
        
        %
        % ax2 = subplot(1,2,2);
        % errBar(1,:) = nanstd(baselinePupilSize_withBadTrials.Melanopsin, [], 1)/sqrt((length(baselinePupilSize_withBadTrials.Melanopsin(:,1))));
        % errBar(2,:) = nanstd(baselinePupilSize_withBadTrials.Melanopsin, [], 1)/sqrt((length(baselinePupilSize_withBadTrials.Melanopsin(:,1))));
        % shadedErrorBar(1:6, nanmean(baselinePupilSize_withBadTrials.Melanopsin, 1), errBar, 'c-o');
        % %plot(nanmean(baselinePupilSize_withBadTrials.Melanopsin,1), 'o')
        % title('Melanopsin')
        % xlabel('Trial Number within Block')
        % ylabel('Normalized Pupil Diameter')
        
    end
    if stimulus == 1
        p = 4;
        subplot(2,4,p);
        errBar(1,:) = nanstd([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})])));
        errBar(2,:) = nanstd([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})])));
        shadedErrorBar(1:24, nanmean([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})], 1), errBar, 'LineProps', colors{stimulus});
        title('Combined Across Sessions')
        ylabel('Normalized Pupil Diameter')
        xlabel('Trial Number Within Block')
        xlim([0.9 24.1])
        ylim([0 1.1])
        
        
    elseif stimulus == 2
        p = 8;
        subplot(2,4,p);
        errBar(1,:) = nanstd([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length(([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})]))));
        errBar(2,:) = nanstd([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})])));
        shadedErrorBar(1:24, nanmean([baselinePupilSize_withBadTrialsNormed{1}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{2}.(stimuli{stimulus}); baselinePupilSize_withBadTrialsNormed{3}.(stimuli{stimulus})], 1), errBar, 'LineProps', colors{stimulus});
        title('Combined Across Sessions')
        ylabel('Normalized Pupil Diameter')
        xlabel('Trial Number Within Block')
        xlim([0.9 24.1])
        ylim([0 1.1])
        
    end
    
    
end

outDir = '~/Desktop';
orient(plotFig, 'landscape')
print(plotFig, fullfile(outDir,'baselineSize_overEntireBlock'), '-dpdf', '-fillpage')
close(plotFig)
%% baseline size
close all
stimuli = {'LMS', 'Melanopsin'};

colors = {'k-o', 'c-o'};
plotFig = figure;
counter = 1;
errBar = [];
for stimulus = 1:2
    for session = 1:3
        if stimulus == 1
            p = session;
        else
            p = session + 4;
        end
        
        ax{counter} = subplot(2,4,p);
        counter = counter + 1;
        errBar(1,:) = nanstd(resultStruct{session}.(stimuli{stimulus}), [], 1)./sqrt((length(resultStruct{session}.(stimuli{stimulus})(:,1))));
        errBar(2,:) = nanstd(resultStruct{session}.(stimuli{stimulus}), [], 1)./sqrt((length(resultStruct{session}.(stimuli{stimulus})(:,1))));
        shadedErrorBar(1:6, nanmean(resultStruct{session}.(stimuli{stimulus}), 1), errBar, 'LineProps', colors{stimulus});
        
        %plot(nanmean(resultStruct.LMS,1), 'o')
        xlabel('Trial Number Between Breaks')
        ylabel('Baseline Pupil Diameter (mm)')
        xlim([0.9 6.1])
        ylim([0 5.5])
        title(['Session ' num2str(session)])
        %suptitle(stimuli{stimulus})
        
        %
        % ax2 = subplot(1,2,2);
        % errBar(1,:) = nanstd(resultStruct.Melanopsin, [], 1)/sqrt((length(resultStruct.Melanopsin(:,1))));
        % errBar(2,:) = nanstd(resultStruct.Melanopsin, [], 1)/sqrt((length(resultStruct.Melanopsin(:,1))));
        % shadedErrorBar(1:6, nanmean(resultStruct.Melanopsin, 1), errBar, 'c-o');
        % %plot(nanmean(resultStruct.Melanopsin,1), 'o')
        % title('Melanopsin')
        % xlabel('Trial Number within Block')
        % ylabel('Normalized Pupil Diameter')
        
    end
    if stimulus == 1
        p = 4;
        subplot(2,4,p);
        errBar(1,:) = nanstd([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})])));
        errBar(2,:) = nanstd([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})])));
        shadedErrorBar(1:6, nanmean([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})], 1), errBar, 'LineProps', colors{stimulus});
        title('Combined Across Sessions')
        ylabel('Normalized Pupil Diameter')
        xlabel('Trial Number Between Breaks')
        xlim([0.9 6.1])
        ylim([0 1.1])
        
        
    elseif stimulus == 2
        p = 8;
        subplot(2,4,p);
        errBar(1,:) = nanstd([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length(([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})]))));
        errBar(2,:) = nanstd([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})], [], 1)/sqrt((length([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})])));
        shadedErrorBar(1:6, nanmean([resultStructNormed{1}.(stimuli{stimulus}); resultStructNormed{2}.(stimuli{stimulus}); resultStructNormed{3}.(stimuli{stimulus})], 1), errBar, 'LineProps', colors{stimulus});
        title('Combined Across Sessions')
        ylabel('Normalized Pupil Diameter')
        xlabel('Trial Number Between Breaks')
        xlim([0.9 6.1])
        ylim([0 1.1])
        
    end
    
    
end

outDir = '~/Desktop';
orient(plotFig, 'landscape')
print(plotFig, fullfile(outDir,'baselineSize'), '-dpdf', '-fillpage')
close(plotFig)

%% amplitude
plotFig = figure;
for stimulus = 1:2
    for session = 1:3
        if stimulus == 1
            p = session;
        else
            p = session + 4;
        end
        subplot(2,4,p);
        numberOfSubjects = size(totalResponseStruct{session}.(stimuli{stimulus}),2);
        
        
        
        
        errBar = [];
        errBar(1,:) = nanstd(totalResponseStruct{session}.(stimuli{stimulus}), [], 1)/sqrt(numberOfSubjects);
        errBar(2,:) = nanstd(totalResponseStruct{session}.(stimuli{stimulus}), [], 1)/sqrt(numberOfSubjects);
        
        
        shadedErrorBar(1:6, mean(totalResponseStruct{session}.(stimuli{stimulus}),1), errBar, 'LineProps', colors{stimulus});
        title(['Session ' num2str(session)]);
        xlabel('Trial Number Between Breaks')
        ylabel('Total Response Area (%change*secs)')
        ylim([-180 -20])
        xlim([0.9 6.1])
        
        
    end
    %linkaxes([ax{1}, ax{2}, ax{3}])
    
    %suptitle(stimuli{stimulus})
    
end

for stimulus = 1:2
    if stimulus == 1
        p = 4;
        subplot(2,4,p);
    elseif stimulus == 2
        p = 8;
        subplot(2,4,p);
    end
    title('Combined Across Sessions')
    numberOfSubjects = (size(totalResponseStruct{1}.(stimuli{stimulus}),2) + size(totalResponseStruct{2}.(stimuli{stimulus}),2) + size(totalResponseStruct{3}.(stimuli{stimulus}),2));
    
    
    
    
    errBar = [];
    errBar(1,:) = nanstd([totalResponseStruct{1}.(stimuli{stimulus}); totalResponseStruct{2}.(stimuli{stimulus}); totalResponseStruct{3}.(stimuli{stimulus})], [], 1)/sqrt(numberOfSubjects);
    errBar(2,:) = nanstd([totalResponseStruct{1}.(stimuli{stimulus}); totalResponseStruct{2}.(stimuli{stimulus}); totalResponseStruct{3}.(stimuli{stimulus})], [], 1)/sqrt(numberOfSubjects);
    
    
    shadedErrorBar(1:6, mean([totalResponseStruct{1}.(stimuli{stimulus}); totalResponseStruct{2}.(stimuli{stimulus}); totalResponseStruct{3}.(stimuli{stimulus})],1), errBar, 'LineProps', colors{stimulus});
    xlabel('Trial Number Between Breaks')
    ylabel('Total Response Area (%change*secs)')
    ylim([-180 -20])
    xlim([0.9 6.1])
    
end

orient(plotFig, 'landscape')

print(plotFig, fullfile(outDir,'amplitude'), '-dpdf', '-fillpage')
close(plotFig)