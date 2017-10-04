function plotSparkline_onlySS(subjects, averageResponsePerSubject, dropboxAnalysisDir)

stimuli = {'LMS' 'Mel'};
color = {[0.3 0.3 0.3], 'b'};
colorDotted = {[0.7 0.7 0.7], [0.5 0.5 1]};

plotFig = figure;
hold on



for ss = 1:length(subjects{2}.ID)
    secondSessionIndex = ss;
    subject = subjects{2}.ID{ss};
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    whichSubject = cellfun(@(x) strcmp(x, subject), subjects{1}.ID);
    [maxValue, firstSessionIndex] = max(whichSubject);
    
    for stimulus = 1:length(stimuli)
        
        
        response1 = averageResponsePerSubject{1}.(stimuli{stimulus})(firstSessionIndex,:);
        response2 = averageResponsePerSubject{2}.(stimuli{stimulus})(secondSessionIndex,:);

        % rather than subplotting, to plot all of the time series on the
        % same plot we're just going to be shifting the different
        % constriction curves over in x and y
        
        % first determine the horizontal shift
        offset = 100;
        xlength = 700;
        if ss <= 12 && stimulus == 1
            x1 = 0;
            x = x1:x1+(xlength-1);
        elseif ss > 12 && stimulus == 1
            x1 = 800;
            x = x1:x1+(xlength-1);
       elseif ss <= 12 && stimulus == 2
            x1 = 1600;
            x = x1:x1+(xlength-1);
        elseif ss > 12 && stimulus == 2
            if ss == 25
                x1 = 1600;
                x = x1:x1+(xlength-1);
            else
                x1 = 2400;
                x = x1:x1+(xlength-1);
            end
        end
        
        % determine the vertical shift
        offset = .50;
        
        if ss <= 12
            response1 = response1 - offset*(ss - 1);
            response2 = response2 - offset*(ss - 1);
        else
            response1 = response1 - offset*(ss - 13);
            response2 = response2 - offset*(ss - 13);
        end
        
        plot(x, response1, 'Color', color{stimulus})
        
        
        
        
        
        
    end
end

ax = gca;
set(ax, 'Visible', 'off')
saveas(plotFig, fullfile(dropboxAnalysisDir, 'pupilPIPRAnalysis/OSAFigures', 'sparkLine_firstSessionOnly.pdf'), 'pdf')


plotFig = figure;
hold on

%%

for ss = 1:length(subjects{2}.ID)
    secondSessionIndex = ss;
    subject = subjects{2}.ID{ss};
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    whichSubject = cellfun(@(x) strcmp(x, subject), subjects{1}.ID);
    [maxValue, firstSessionIndex] = max(whichSubject);
    
    for stimulus = 1:length(stimuli)
        
        
        response1 = averageResponsePerSubject{1}.(stimuli{stimulus})(firstSessionIndex,:);
        response2 = averageResponsePerSubject{2}.(stimuli{stimulus})(secondSessionIndex,:);

        % rather than subplotting, to plot all of the time series on the
        % same plot we're just going to be shifting the different
        % constriction curves over in x and y
        
        % first determine the horizontal shift
        offset = 100;
        xlength = 700;
        if ss <= 12 && stimulus == 1
            x1 = 0;
            x = x1:x1+(xlength-1);
        elseif ss > 12 && stimulus == 1
            x1 = 800;
            x = x1:x1+(xlength-1);
       elseif ss <= 12 && stimulus == 2
            x1 = 1600;
            x = x1:x1+(xlength-1);
        elseif ss > 12 && stimulus == 2
            if ss == 25
                x1 = 1600;
                x = x1:x1+(xlength-1);
            else
                x1 = 2400;
                x = x1:x1+(xlength-1);
            end
        end
        
        % determine the vertical shift
        offset = .50;
        
        if ss <= 12
            response1 = response1 - offset*(ss - 1);
            response2 = response2 - offset*(ss - 1);
        else
            response1 = response1 - offset*(ss - 13);
            response2 = response2 - offset*(ss - 13);
        end
        
        plot(x, response1, '-.', 'Color', colorDotted{stimulus}, 'LineWidth', 3)
        plot(x, response2, 'Color', color{stimulus})
        
        
        
        
        
        
    end
end

ax = gca;
set(ax, 'Visible', 'off')
saveas(plotFig, fullfile(dropboxAnalysisDir, 'pupilPIPRAnalysis/OSAFigures', 'sparkLine.pdf'), 'pdf')
% now figure out subjects who haven't been scanned twice

% variable for subject indices not scanned twice
% notScannedTwice = [];
% 
% for ss = 1:length(subjects{1}.ID)
%     scannedTwice = 0;
%     for ss2 = 1:length(subjects{2}.ID)
%         if strcmp(subjects{1}.ID{ss}, subjects{2}.ID{ss2})
%             scannedTwice = 1;
%         end
%     end
%     if scannedTwice == 0
%         notScannedTwice = [notScannedTwice, ss];
%     end
% end
% 
% for ss = 1:length(notScannedTwice)
%     for stimulus = 1:length(stimuli)
%         response1 = averageResponsePerSubject{1}.(stimuli{stimulus})(notScannedTwice(ss),:);
%         
%         
%         % rather than subplotting, to plot all of the time series on the
%         % same plot we're just going to be shifting the different
%         % constriction curves over in x and y
%         
%         % first determine the horizontal shift
%         offset = 100;
%         xlength = 700;
%         x1 = xlength*(stimulus-1)+offset*(stimulus-1);
%         x = x1:x1+(xlength-1);
%         
%         % determine the vertical shift
%         offset = .50;
%         
%         response1 = response1 - offset*(ss + 25 - 1);
%         
%         plot(x, response1, '-.', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 2)
%     end
% end
% 
% % now spruce it up to make it look nice
% % turn off the axes
% ax = gca;
% set(ax, 'Visible', 'off')
% % add label so we know which plot is which
% text(315, 0.55, 'LMS')
% text(990, 0.55, 'Melanopsin')
% text(1900, 0.55, 'Blue')
% text(2700, 0.55, 'Red')
% % add line for scale
% line([0 250], [0, 0])
% line([0 0], [0, -0.5])
% 
% 
% 
% outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/sparkLine');
% 
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% 
% 
% saveas(plotFig, fullfile(outDir, ['sparkLine.pdf']), 'pdf');
% 
% outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
% if ~exist(outDir, 'dir')
%     mkdir(outDir);
% end
% saveas(plotFig, fullfile(outDir, ['2b.pdf']), 'pdf');
% 
% 
% close(plotFig);

end
