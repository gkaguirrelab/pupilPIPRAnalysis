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
p.addParameter('xLabel','',@ischar);
p.addParameter('yLabel','',@ischar);
p.addParameter('title','',@ischar);

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
    for row = 1:size(p.Results.sessionOneErrorBar,1)
       counter = 1;
        for ss = 1:length(sessionTwoSubjectList) % loop over subjects that have completed both sessions
            subject = sessionTwoSubjectList(ss);
            
            secondSessionIndex = ss;
            whichSubject = cellfun(@(x) strcmp(x, subject), sessionOneSubjectList);
            
            if sum(whichSubject) ~= 0
                [maxValue, firstSessionIndex] = max(whichSubject);
                pairedResult.sessionOneErrorBar(row,counter) = p.Results.sessionOneErrorBar(row,firstSessionIndex);
                pairedResult.sessionTwoErrorBar(row,counter) = p.Results.sessionTwoErrorBar(row,secondSessionIndex);
                counter = counter + 1;
            end
            
        end
    end
end

%% do the plotting
if p.Results.makePlot
    if ~isempty(p.Results.saveName)
        plotFig = figure;
    end
    
    if isempty(p.Results.sessionOneErrorBar)
        prettyScatterplots(pairedResult.sessionOne, pairedResult.sessionTwo, 'unity', 'on', 'xLim', p.Results.xLims, 'yLim', p.Results.yLims, 'significance', p.Results.significance, 'xLabel', p.Results.xLabel, 'yLabel', p.Results.yLabel, 'plotOption', 'square', 'title', p.Results.title)
        
    else
        prettyScatterplots(pairedResult.sessionOne, pairedResult.sessionTwo, 'xError', pairedResult.sessionOneErrorBar, 'yError', pairedResult.sessionTwoErrorBar, 'unity', 'on', 'xLim', p.Results.xLims, 'yLim', p.Results.yLims, 'significance', p.Results.significance, 'xLabel', p.Results.xLabel, 'yLabel', p.Results.yLabel, 'plotOption', 'square', 'title', p.Results.title)
        
    end
    if ~isempty(p.Results.saveName)
        outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis', p.Results.subdir);
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        saveas(plotFig, fullfile(outDir, [p.Results.saveName, '.pdf']), 'pdf')
    end
end
end % end function