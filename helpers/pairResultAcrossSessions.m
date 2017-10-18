function [ pairedResult ]  = pairResultAcrossSessions(sessionOneSubjectList, sessionTwoSubjectList, sessionOneResult, sessionTwoResult, dropboxAnalysisDir, varargin)

dbstop if error

%% Parse input
p = inputParser; p.KeepUnmatched = true;


p.addParameter('makePlot',true,@islogical);
p.addParameter('significance','rho',@ischar);
p.addParameter('subdir','',@ischar);
p.addParameter('saveName','',@ischar);
p.addParameter('sessionOneErrorBar','',@isnumeric);
p.addParameter('sessionTwoErrorBar','',@isnumeric);
p.addParameter('xLims',[0 10],@isnumeric);
p.addParameter('yLims',[0 10],@isnumeric);

p.parse(varargin{:});


%% do the pairing
pairedResult.sessionOne = [];
pairedResult.sessionTwo = [];
pairedResult.subjectKey = [];

for ss = 1:length(sessionTwoSubjectList) % loop over subjects that have completed both sessions
    subject = sessionTwoSubjectList(ss);
    
    secondSessionIndex = ss;
    whichSubject = cellfun(@(x) strcmp(x, subject), sessionOneSubjectList);
    if sum(whichSubject) ~= 0
        [maxValue, firstSessionIndex] = max(whichSubject);
        pairedResult.sessionOne = [pairedResult.sessionOne, sessionOneResult(firstSessionIndex)];
        pairedResult.sessionTwo = [pairedResult.sessionTwo, sessionTwoResult(secondSessionIndex)];
        pairedResult.subjectKey = [pairedResult.subjectKey, sessionTwoSubjectList(ss)];
    end
    
end


% now do the pairing for the error bars if called for
if isempty(p.Results.sessionOneErrorBar)
else
    pairedResult.sessionOneErrorBar = [];
    pairedResult.sessionTwoErrorBar = [];
    for ss = 1:length(sessionTwoSubjectList) % loop over subjects that have completed both sessions
        subject = sessionTwoSubjectList(ss);
        
        secondSessionIndex = ss;
        whichSubject = cellfun(@(x) strcmp(x, subject), sessionOneSubjectList);
        if sum(whichSubject) ~= 0
            [maxValue, firstSessionIndex] = max(whichSubject);
            pairedResult.sessionOneErrorBar = [pairedResult.sessionOneErrorBar, p.Results.sessionOneErrorBar(firstSessionIndex)];
            pairedResult.sessionTwoErrorBar = [pairedResult.sessionTwoErrorBar, p.Results.sessionTwoErrorBar(secondSessionIndex)];
        end
        
    end
end

%% do the plotting
if p.Results.makePlot
    plotFig = figure;
    hold on
    plot(-1000:1000, -1000:1000, '-.', 'Color', 'k')
    if isempty(p.Results.sessionOneErrorBar)
        prettyScatterplots(pairedResult.sessionOne, pairedResult.sessionTwo, 0*pairedResult.sessionOne, 0*pairedResult.sessionOne, 'xLim', p.Results.xLims, 'yLim', p.Results.yLims, 'significance', p.Results.significance)
        
    else
        prettyScatterplots(pairedResult.sessionOne, pairedResult.sessionTwo, pairedResult.sessionOneErrorBar, pairedResult.sessionTwoErrorBar, 'xLim', p.Results.xLims, 'yLim', p.Results.yLims, 'significance', p.Results.significance)
        
    end
    if ~isempty(p.Results.saveName)
        outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis', p.Results.subdir, 'testRetest');
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [p.Results.saveName, '.png']), 'png')
    end
end
end % end function