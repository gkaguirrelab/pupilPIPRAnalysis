function plotSparkline(subjects, averageBlueCombined, averageLMSCombined, averageMelCombined, averageRedCombined, semBlue, semLMS, semMel, semRed, dropboxAnalysisDir)

stimulusOrder = {'LMS' 'Melanopsin' 'Blue' 'Red'};


plotFig = figure;
hold on



for ss = 1:size(averageBlueCombined{2},1)
    secondSessionIndex = ss;
    subject = subjects{2}{1}(ss,:);
    % determine the index corresponding to the same subject in the list of
    % subjects having successfully completed the first session
    for x = 1:size(subjects{1}{1},1)
        if strcmp(subjects{1}{1}(x,:),subject);
            firstSessionIndex = x;
        end
    end
    
    for stimulus = 1:length(stimulusOrder)
        if stimulus == 1 % LMS
            response1 = averageLMSCombined{1}(firstSessionIndex,:);
            response2 = averageLMSCombined{2}(secondSessionIndex,:);
            error = semLMS;
        elseif stimulus == 2 % mel
            response1 = averageMelCombined{1}(firstSessionIndex,:);
            response2 = averageMelCombined{2}(secondSessionIndex,:);
            
            error = semMel;
        elseif stimulus == 3 % blue
            response1 = averageBlueCombined{1}(firstSessionIndex,:);
            response2 = averageBlueCombined{2}(secondSessionIndex,:);
            
            error = semBlue;
        elseif stimulus == 4 % red
            response1 = averageRedCombined{1}(firstSessionIndex,:);
            response2 = averageRedCombined{2}(secondSessionIndex,:);
            
            error = semRed;
        end
        
        % rather than subplotting, to plot all of the time series on the
        % same plot we're just going to be shifting the different
        % constriction curves over in x and y
        
        % first determine the horizontal shift
        offset = 100;
        xlength = 700;
        x1 = xlength*(stimulus-1)+offset*(stimulus-1);
        x = x1:x1+(xlength-1);
        
        % determine the vertical shift
        offset = .50;
        
        response1 = response1 - offset*(ss - 1);
        response2 = response2 - offset*(ss - 1);
        
        plot(x, response1, 'Color', 'k')
        plot(x, response2, 'Color', 'b')
        
        
        
        
        
        
    end
end

% now figure out subjects who haven't been scanned twice

% variable for subject indices not scanned twice
notScannedTwice = [];

for ss = 1:size(subjects{1}{1},1)
    scannedTwice = 0;
    for ss2 = 1:size(subjects{2}{1},1)
        if strcmp(subjects{1}{1}(ss,:), subjects{2}{1}(ss2,:))
            scannedTwice = 1;
        end
    end
    if scannedTwice == 0
        notScannedTwice = [notScannedTwice, ss];
    end
end

for ss = 1:length(notScannedTwice)
    for stimulus = 1:length(stimulusOrder)
        if stimulus == 1 % LMS
            response1 = averageLMSCombined{1}(notScannedTwice(ss),:);
            error = semLMS;
        elseif stimulus == 2 % mel
            response1 = averageMelCombined{1}(notScannedTwice(ss),:);
            
            error = semMel;
        elseif stimulus == 3 % blue
            response1 = averageBlueCombined{1}(notScannedTwice(ss),:);
            
            error = semBlue;
        elseif stimulus == 4 % red
            response1 = averageRedCombined{1}(notScannedTwice(ss),:);
            
            error = semRed;
        end
        
        % rather than subplotting, to plot all of the time series on the
        % same plot we're just going to be shifting the different
        % constriction curves over in x and y
        
        % first determine the horizontal shift
        offset = 100;
        xlength = 700;
        x1 = xlength*(stimulus-1)+offset*(stimulus-1);
        x = x1:x1+(xlength-1);
        
        % determine the vertical shift
        offset = .50;
        
        response1 = response1 - offset*(ss + 25 - 1);
        
        plot(x, response1, 'Color', 'k')
    end
end

% now spruce it up to make it look nice
% turn off the axes
ax = gca;
set(ax, 'Visible', 'off')
% add label so we know which plot is which
text(315, 0.55, 'LMS')
text(990, 0.55, 'Melanopsin')
text(1900, 0.55, 'Blue')
text(2700, 0.55, 'Red')
% add line for scale
line([0 250], [0, 0])
line([0 0], [0, -0.5])



outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/dataOverview/sparkLine');




saveas(plotFig, fullfile(outDir, ['sparkLine.pdf']), 'pdf');

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['2a.pdf']), 'pdf');


close(plotFig);

end
