function plotSparkline(subjects, averageResponsePerSubject, dropboxAnalysisDir)

stimuli = {'LMS' 'Mel' 'Blue' 'Red'};


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
        x1 = xlength*(stimulus-1)+offset*(stimulus-1);
        x = x1:x1+(xlength-1);
        
        % determine the vertical shift
        offset = .50;
        
        response1 = response1 - offset*(ss - 1);
        response2 = response2 - offset*(ss - 1);
        
        plot(x, response1, '-.', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 2)
        plot(x, response2, 'Color', 'b')
        
        
        
        
        
        
    end
end

% now figure out subjects who haven't been scanned twice

% variable for subject indices not scanned twice
notScannedTwice = [];

for ss = 1:length(subjects{1}.ID)
    scannedTwice = 0;
    for ss2 = 1:length(subjects{2}.ID)
        if strcmp(subjects{1}.ID{ss}, subjects{2}.ID{ss2})
            scannedTwice = 1;
        end
    end
    if scannedTwice == 0
        notScannedTwice = [notScannedTwice, ss];
    end
end

for ss = 1:length(notScannedTwice)
    for stimulus = 1:length(stimuli)
        response1 = averageResponsePerSubject{1}.(stimuli{stimulus})(notScannedTwice(ss),:);
        
        
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
        
        plot(x, response1, '-.', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 2)
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

if ~exist(outDir, 'dir')
    mkdir(outDir);
end


saveas(plotFig, fullfile(outDir, ['sparkLine.pdf']), 'pdf');

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
saveas(plotFig, fullfile(outDir, ['2b.pdf']), 'pdf');


close(plotFig);

end
