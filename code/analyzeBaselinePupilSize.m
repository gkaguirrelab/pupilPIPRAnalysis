function [baselinePupilSize] = analyzeBaselinePupilSize(goodSubjects, dropboxAnalysisDir, varargin)

% This function looks at the baseline size, which here refers to the mean
% pupil size preceeding any light pulses during the 6 trials of background
% adaptation. The motivation for this analysis was basically to confirm
% that the our stimuli was having some of the basic effects we would expect
% on pupil size, namely that was increased the luminance of the background
% spectra that pupil size would get smaller.

% INPUT:
%   - goodSubjects: list of subjects and associated dates when they
%           were studied. This is necessary to specify which subjects were
%           studied when to go look up their raw data
%   - dropboxAnalysisDir: string that defines the path to the dropbox
%           directory so we know where the data lives

% OUTPUT:
%   - baselinePupilSize: a 1x3 cell array, where each cell refers to a
%           different session. The contents of each cell is a structure,
%           where each subfield of the structure is a stimulus type (Mel,
%           LMS, or PIPR). The concents of each subfield is a vector of
%           length N, where N is the number of subjects studied in that
%           session

% OPTIONS:
%   - whichTrials: a key value pair to specify which background trials to
%           include in this analysis. The default is to use all background
%           trials, but another sensible option is to just use the last
%           trial (when the pupil is more or less fully adapted)


%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;
p.addRequired('goodSubjects',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);


% Optional analysis parameters
p.addParameter('stimulusLabels',{'LMS' 'Mel' 'Blue' 'Red'},@iscell);
p.addParameter('whichTrials','all',@ischar);



%% Parse and check the parameters
p.parse(goodSubjects, dropboxAnalysisDir, varargin{:});


% a way to link the stimulus described in the stimuli vector above, with
% where that data lives (the blue and red are PIPR stimuli, and are located
% within the same folder.
stimuliType = {'LMS', 'Mel', 'PIPR'};




for session = 1:length(goodSubjects)
    if session == 1 || session == 2
        subdir = '';
    elseif session == 3
        subdir = 'Legacy';
    end
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        
        for stimulus = 1:length(stimuliType)
            % determine where the raw data for each trial lives. this
            % depends on the stimulus
            csvFileName = dir(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, [subject, '_PupilPulseData_Background_Mean.csv']));
            csvFileName = csvFileName.name;
            
            allTrials = [];
            allTrials = importdata(fullfile(dropboxAnalysisDir, subdir, ['PIPRMaxPulse_Pulse', stimuliType{stimulus}], subject, date, csvFileName));
            if strcmp(p.Results.whichTrials, 'all')
                whichTrials = 1:length(allTrials);
            elseif strcmp(p.Results.whichTrials, 'last')
                whichTrials = length(allTrials);
            end
            baselinePupilSize{session}.(stimuliType{stimulus})(ss) = nanmean(allTrials(whichTrials));
            
            
            
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions

%% now do some plotting to summarize
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/baselinePupilSize');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuliType)
    
    
    subplot(1,3,stimulus)
    pbaspect([1 1 1])
    title(stimuliType{stimulus});
    xlabel('Session')
    ylabel('Pupil Diameter (mm)')
    
    data = {baselinePupilSize{1}.(stimuliType{stimulus})', baselinePupilSize{2}.(stimuliType{stimulus})', baselinePupilSize{3}.(stimuliType{stimulus})'};
    plotSpread(data,  'xNames', {'S 1', 'S 2', 'S 3'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
    ylim([2 10])
    ylabel('Pupil Diameter (mm)')
end
print(plotFig, fullfile(outDir,'baselinePupilSize_sessions123'), '-dpdf', '-bestfit')
close(plotFig)

% now combine the first and second session
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuliType)
    
    
    subplot(1,3,stimulus)
    pbaspect([1 1 1])
    title(stimuliType{stimulus});
    xlabel('Session')
    ylabel('Pupil Diameter (mm)')
    
    [combinedBaselinePupilSize] = combineResultAcrossSessions(goodSubjects, baselinePupilSize{1}.(stimuliType{stimulus}), baselinePupilSize{2}.(stimuliType{stimulus}));
    
    data = {combinedBaselinePupilSize.result', baselinePupilSize{3}.(stimuliType{stimulus})'};
    plotSpread(data,  'xNames', {'S 1/2', 'S 3'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
    ylim([2 10])
    ylabel('Pupil Diameter (mm)')
end
print(plotFig, fullfile(outDir,'baselinePupilSize_sessions12combined3'), '-dpdf', '-bestfit')
close(plotFig)

% make sure our background luminance is behaving as we expect
stimuliTypeValidation = {'LMS', 'Melanopsin', 'PIPR'};
for session = 1:3
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        [ passStatus, validation, medianMelanopsinBackgroundLuminance ] = analyzeValidation(subject, date, dropboxAnalysisDir, 'plot', 'off');
        if passStatus == 0
            subject
            date
        end
        for stimulus = 1:length(stimuliTypeValidation)
            if strcmp(stimuliTypeValidation{stimulus}, 'PIPR')
                medianValidation{session}.PIPR(ss) = (median([validation.Blue.backgroundLuminance])+median([validation.Red.backgroundLuminance]))/2;
            else
                medianValidation{session}.(stimuliTypeValidation{stimulus})(ss) = median([validation.(stimuliTypeValidation{stimulus}).backgroundLuminance]);
            end
        end
    end
end


plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuliType)
    
    
    subplot(1,3,stimulus)
    pbaspect([1 1 1])
    title(stimuliType{stimulus});
    xlabel('Session')
    ylabel('Luminance (cd/m2)')
    
    data = {medianValidation{1}.(stimuliTypeValidation{stimulus})', medianValidation{2}.(stimuliTypeValidation{stimulus})', medianValidation{3}.(stimuliTypeValidation{stimulus})'};
    plotSpread(data,  'xNames', {'S 1', 'S 2', 'S 3'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
    ylabel('Luminance (cd/m2)')
    
end
print(plotFig, fullfile(outDir,'backgroundLuminance_sessions123'), '-dpdf', '-bestfit')
close(plotFig)

% now combine the first and second session
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.3])
for stimulus = 1:length(stimuliType)
    
    
    subplot(1,3,stimulus)
    pbaspect([1 1 1])
    title(stimuliType{stimulus});
    xlabel('Session')
    ylabel('Luminance (cd/m2)')
    
    [combinedMedianValidation] = combineResultAcrossSessions(goodSubjects, medianValidation{1}.(stimuliTypeValidation{stimulus}), medianValidation{2}.(stimuliTypeValidation{stimulus}));
    
    data = {combinedMedianValidation.result', medianValidation{3}.(stimuliTypeValidation{stimulus})'};
    plotSpread(data,  'xNames', {'S 1/2', 'S 3'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
    ylabel('Luminance (cd/m2)')
    
end
print(plotFig, fullfile(outDir,'backgroundLuminance_sessions12combined3'), '-dpdf', '-bestfit')
close(plotFig)

%% now to look at paired difference in pupil size bewteen session 3 and session 1/2 combined
for stimulus = 1:length(stimuliType)
    [combinedBaselinePupilSize.(stimuliType{stimulus}) ] = combineResultAcrossSessions(goodSubjects, baselinePupilSize{1}.(stimuliType{stimulus}), baselinePupilSize{2}.(stimuliType{stimulus}));
    [pairedBaselinePupilSize.(stimuliType{stimulus})] = pairResultAcrossSessions(combinedBaselinePupilSize.(stimuliType{stimulus}).subjectKey, goodSubjects{3}.ID, combinedBaselinePupilSize.(stimuliType{stimulus}).result,  baselinePupilSize{3}.(stimuliType{stimulus}), dropboxAnalysisDir, 'makePlot', false);
end

plotFig = figure;
data = {pairedBaselinePupilSize.Mel.sessionOne' - pairedBaselinePupilSize.Mel.sessionTwo', pairedBaselinePupilSize.LMS.sessionOne' - pairedBaselinePupilSize.LMS.sessionTwo', pairedBaselinePupilSize.PIPR.sessionOne' - pairedBaselinePupilSize.PIPR.sessionTwo'};
plotSpread(data,  'xNames', {'Mel', 'LMS', 'PIPR'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
ylabel('Session 1/2 - Session 3 (mm)')
print(plotFig, fullfile(outDir,'pairedPupilDifference_mm'), '-dpdf', '-bestfit')
close(plotFig)

plotFig = figure;
data = {100*(pairedBaselinePupilSize.Mel.sessionOne' - pairedBaselinePupilSize.Mel.sessionTwo')./pairedBaselinePupilSize.Mel.sessionOne', 100*(pairedBaselinePupilSize.LMS.sessionOne' - pairedBaselinePupilSize.LMS.sessionTwo')./pairedBaselinePupilSize.LMS.sessionOne', 100*(pairedBaselinePupilSize.PIPR.sessionOne' - pairedBaselinePupilSize.PIPR.sessionTwo')./pairedBaselinePupilSize.PIPR.sessionOne'};
plotSpread(data,  'xNames', {'Mel', 'LMS', 'PIPR'}, 'distributionMarkers', 'o', 'showMM', 1, 'binWidth', 0.3)
ylabel('(Session 1/2 - Session 3)/(Session 1/2) (%)')
print(plotFig, fullfile(outDir,'pairedPupilDifference_percent'), '-dpdf', '-bestfit')
close(plotFig)

end % end function