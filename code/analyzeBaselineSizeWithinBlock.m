stimuli = {'LMS', 'Melanopsin'};

for session = 1:3
    resultStruct{session}.Melanopsin = [];
    resultStruct{session}.LMS = [];
    resultStructNormed{session}.Melanopsin = [];
    resultStructNormed{session}.LMS = [];
end

for stimulus = 1:length(stimuli)    
    for session = 1:3
        sessionMeanDiameter(session) = nanmean(baselineSizeStruct{session}.(stimuli{stimulus})(:,1));
        for bb = 1:4
            resultStruct{session}.(stimuli{stimulus}) = [resultStruct{session}.(stimuli{stimulus}); (baselineSizeStruct{session}.(stimuli{stimulus})(:,(bb*6-5):(bb*6)))];
            
        end
    end
end

for stimulus = 1:length(stimuli)    
    for session = 1:3
        for bb = 1:4
            resultStructNormed{session}.(stimuli{stimulus}) = [resultStructNormed{session}.(stimuli{stimulus}); (baselineSizeStruct{session}.(stimuli{stimulus})(:,(bb*6-5):(bb*6)))];
            
        end
        resultStructNormed{session}.(stimuli{stimulus}) = resultStructNormed{session}.(stimuli{stimulus})./nanmean(resultStructNormed{session}.(stimuli{stimulus})(:,1));
    end
end

close all
colors = {'k-o', 'c-o'};
counter = 1;
for stimulus = 1:2
    figure;
    for session = 1:3
        
        ax{counter} = subplot(1,3,session);
        counter = counter + 1;
        errBar(1,:) = nanstd(resultStruct{session}.(stimuli{stimulus}), [], 1)/sqrt((length(resultStruct{session}.(stimuli{stimulus})(:,1))));
        errBar(2,:) = nanstd(resultStruct{session}.(stimuli{stimulus}), [], 1)/sqrt((length(resultStruct{session}.(stimuli{stimulus})(:,1))));
        shadedErrorBar(1:6, nanmean(resultStruct{session}.(stimuli{stimulus}), 1), errBar, 'LineProps', colors{stimulus});
        
        %plot(nanmean(resultStruct.LMS,1), 'o')
        xlabel('Trial Number within Block')
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
                %linkaxes([ax{1}, ax{2}, ax{3}])
    elseif stimulus == 2
                %linkaxes([ax{4}, ax{5}, ax{6}])
    end


end
       % linkaxes([ax{1}, ax{2}, ax{3}, ax{4}, ax{5}, ax{6}])
