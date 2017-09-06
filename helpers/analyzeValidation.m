function [ passStatus, validation, medianMelanopsinBackgroundLuminance ] = analyzeValidation(subject, date, dropboxAnalysisDir, varargin)

% date option
% default is third session, but i need a way to look up other subjects
% by date (for my exclude subjecgts scripts

%% Parse input
p = inputParser; p.KeepUnmatched = true;

p.addParameter('whichValidation','combined',@ischar);
p.addParameter('plot','on',@ischar);
p.addParameter('verbose','off',@ischar);


p.parse(varargin{:});

%% Figure out where the relevant session folder lives

% First look in the new Legacy dir within the current MELA_materials dir
if exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials', 'Legacy', 'PIPRMaxPulse', date)), 'dir')
    subdir = '../MELA_materials/Legacy/PIPRMaxPulse';
elseif exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials_Through061317', 'PIPRMaxPulse', date)), 'dir')
    subdir = '../MELA_materials_Through061317/PIPRMaxPulse';
else
    sprintf('No Session Found for Given Date (%s)', date)
    return
end

% basedon the 'whichValidation' key-value pair, determine which validation
% measurements we care about
if strcmp(p.Results.whichValidation, 'pre')
    firstValidationIndex = 1;
    lastValidationIndex = 5;
elseif strcmp(p.Results.whichValidation, 'post')
    firstValidationIndex = 6;
    lastValidationIndex = 10;
elseif strcmp(p.Results.whichValidation, 'combined')
    firstValidationIndex = 1;
    lastValidationIndex = 10;
end

%% Now start collecting the stats
% set up some variables
stimuli = {'Melanopsin', 'LMS', 'Blue', 'Red'};

failStatus = 0;


for stimulus = 1:length(stimuli)
    if strcmp(stimuli(stimulus), 'Melanopsin')
        validationFolder = ['Cache-MelanopsinDirectedSuperMaxMel_' subject '_' date];
        %validationStruct = validation.MelanopsinStimulation;
        
    elseif strcmp(stimuli(stimulus), 'LMS')
        validationFolder = ['Cache-LMSDirectedSuperMaxLMS_' subject '_' date];
        %validationStruct = validation.LMSStimulation;
        
    elseif strcmp(stimuli(stimulus), 'Blue')
        validationFolder = ['Cache-PIPRBlue_' subject '_' date];
        %validationStruct = validation.BlueStimulation;
        
    elseif strcmp(stimuli(stimulus), 'Red')
        validationFolder = ['Cache-PIPRRed_' subject '_' date];
        %validationStruct = validation.RedStimulation;
        
    end
    
    
    
    availableValidations = dir(fullfile(dropboxAnalysisDir, subdir, date, validationFolder));
    availableValidations = availableValidations(arrayfun(@(x) x.name(1), availableValidations) ~='.'); % discard the . .. and .DSStore dirs
    numberValidations = size(availableValidations,1);
    if lastValidationIndex - firstValidationIndex+1 > numberValidations
        failStatus = failStatus + 1; % if we're trying to analyze more validation files than are available, that's a fail
        passStatus = 0;
        return
    else
        if stimulus == 1;
            if strcmp(p.Results.verbose, 'on')
                sprintf('Of %s total validations, analyzing validation files %s to %s', num2str(numberValidations), num2str(firstValidationIndex), num2str(lastValidationIndex))
            end
        end
        
        if strcmp(stimuli(stimulus), 'Melanopsin') || strcmp(stimuli(stimulus), 'LMS')
            
            for ii = firstValidationIndex:lastValidationIndex
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.txt']);
                validationResultsFile = {validationResultsFile.name};
                fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
                
                fileID = fopen(fullValidationResultsFile);
                textFileContents = textscan(fileID, '%s', 'Delimiter', ' ');
                fclose('all');
                
                backgroundLuminance = str2num(textFileContents{1}{4});
                SConeContrast = str2num(textFileContents{1}{60});
                LMinusMContrast = str2num(textFileContents{1}{53});
                LMSContrast = str2num(textFileContents{1}{44});
                MelanopsinContrast = str2num(textFileContents{1}{67});
                
                validation.(stimuli{stimulus})(ii).SConeContrast = SConeContrast;
                validation.(stimuli{stimulus})(ii).LMinusMContrast = LMinusMContrast;
                validation.(stimuli{stimulus})(ii).LMSContrast = LMSContrast;
                validation.(stimuli{stimulus})(ii).MelanopsinContrast = MelanopsinContrast;
                validation.(stimuli{stimulus})(ii).backgroundLuminance = backgroundLuminance;
            end
        end
        if strcmp(stimuli(stimulus), 'Blue') || strcmp(stimuli(stimulus), 'Red')
            
            for ii = firstValidationIndex:lastValidationIndex
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.txt']);
                validationResultsFile = {validationResultsFile.name};
                fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
                
                fileID = fopen(fullValidationResultsFile);
                textFileContents = textscan(fileID, '%s', 'Delimiter', ' ');
                
                backgroundLuminance = str2num(textFileContents{1}{4});
                
                validation.(stimuli{stimulus})(ii).backgroundLuminance = backgroundLuminance;
            end
        end
    end
end % end loop over stimuli

%% Determine if subject meets inclusion criteria
 
for stimulus = 1:length(stimuli)
    if strcmp(stimuli(stimulus), 'LMS') || strcmp(stimuli(stimulus), 'Melanopsin')
        SConeContrastVector = cell2mat({validation.(stimuli{stimulus}).SConeContrast});
        LMSContrastVector = cell2mat({validation.(stimuli{stimulus}).LMSContrast});
        LMinusMContrastVector = cell2mat({validation.(stimuli{stimulus}).LMinusMContrast});
        MelanopsinContrastVector = cell2mat({validation.(stimuli{stimulus}).MelanopsinContrast});
        if strcmp(stimuli(stimulus), 'LMS')
            if strcmp(p.Results.whichValidation, 'pre') || strcmp(p.Results.whichValidation, 'combined')
                if median(LMSContrastVector(1:5)) < 3.5
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-LMS contrast for LMS stimulation too low')
                    end
                end
                if median(SConeContrastVector(1:5)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-SCone contrast for LMS stimulation too high')
                    end
                end
                if median(LMinusMContrastVector(1:5)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-L-M contrast for LMS stimulation too high')
                    end
                end
                if median(MelanopsinContrastVector(1:5)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-Melanopsin contrast for LMS stimulation too high')
                    end
                end
            end
            if strcmp(p.Results.whichValidation, 'post') || strcmp(p.Results.whichValidation, 'combined')
                if median(LMSContrastVector(6:10)) < 3.5
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-LMS contrast for LMS stimulation too low')
                    end
                end
                if median(SConeContrastVector(6:10)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-SCone contrast for LMS stimulation too high')
                    end
                end
                if median(LMinusMContrastVector(6:10)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-L-M contrast for LMS stimulation too high')
                    end
                end
                if median(MelanopsinContrastVector(6:10)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-Melanopsin contrast for LMS stimulation too high')
                    end
                    
                end
            end
            
            
            
            
            
            
            
        end
        
        
        if strcmp(stimuli(stimulus), 'Melanopsin')
            if strcmp(p.Results.whichValidation, 'pre') || strcmp(p.Results.whichValidation, 'combined')
                
                if median(MelanopsinContrastVector(1:5)) < 3.5
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-Melanopsin contrast for Melanopsin stimulation too low')
                    end
                end
                if median(SConeContrastVector(1:5)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-SCone contrast for Melanopsin stimulation too high')
                    end
                    
                end
                if median(LMinusMContrastVector(1:5)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-L-M contrast for Melanopsin stimulation too high')
                    end
                    
                end
                if median(LMSContrastVector(1:5)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Pre-LMS contrast for Melanopsin stimulation too high')
                    end
                    
                end
            end
            if strcmp(p.Results.whichValidation, 'post') || strcmp(p.Results.whichValidation, 'combined')
                if median(MelanopsinContrastVector(6:10)) < 3.5
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-Melanopsin contrast for Melanopsin stimulation too low')
                    end
                end
                if median(SConeContrastVector(6:10)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-SCone contrast for Melanopsin stimulation too high')
                    end
                    
                end
                if median(LMinusMContrastVector(6:10)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-L-M contrast for Melanopsin stimulation too high')
                    end
                    
                end
                if median(LMSContrastVector(6:10)) > 0.2
                    failStatus = failStatus + 1;
                    if strcmp(p.Results.verbose, 'on')
                        
                        sprintf('Post-LMS contrast for Melanopsin stimulation too high')
                    end
                    
                end
            end % end loop over post/combined
        end % end loop over melanopsin
    end % end loop over melanopsin or LMS
end % end loop over all stimuli

if failStatus > 0
    passStatus = 0;
else
    passStatus = 1;
end

%% summarize background light intensity
% we're going to keep track of melanopsin background light intensity as
% some proxy of overall light bulb output
melanopsinBackgroundLuminanceVector = cell2mat({validation.Melanopsin.backgroundLuminance});
medianMelanopsinBackgroundLuminance = median(melanopsinBackgroundLuminanceVector);
% at the start of the experiment, with a 0.2 ND filter in, we had a
% background luminance of around 270 cd/m2. we plan to switch to a 0.1 ND filter
% when the background luminance hits 215 with the 0.2 ND filter. That way
% when we switch to the 0.1 ND filter, our background luminance should go
% back up to where we started, ~270 cd/m2.
if strcmp(p.Results.verbose, 'on')
    if medianMelanopsinBackgroundLuminance < 215
        sprintf('Median background luminance for melanopsin is %s. Time to change ND filter', medianMelanopsinBackgroundLuminance)
    elseif medianMelanopsinBackgroundLuminance < 225
        sprintf('Median background luminance for melanopsin is %s. Probably need to change ND filter soon', medianMelanopsinBackgroundLuminance)
    end
end



%% plot to summarize results
if strcmp(p.Results.plot, 'on')
    %plotFig = figure;
    set(gcf,'un','n','pos',[.05,.05,.7,.6])
    for stimulus = 1:length(stimuli)
        if strcmp(stimuli(stimulus), 'LMS') || strcmp(stimuli(stimulus), 'Melanopsin')
            SConeContrastVector = cell2mat({validation.(stimuli{stimulus}).SConeContrast});
            LMSContrastVector = cell2mat({validation.(stimuli{stimulus}).LMSContrast});
            LMinusMContrastVector = cell2mat({validation.(stimuli{stimulus}).LMinusMContrast});
            MelanopsinContrastVector = cell2mat({validation.(stimuli{stimulus}).MelanopsinContrast});
            
            subplot(1,2,stimulus)
            
            title(stimuli(stimulus));
            
            
            
            % determine the appropriate y-axis limits
            if strcmp(stimuli(stimulus), 'LMS')
                intendedContrastVector = LMSContrastVector;
                splatterVectors = [SConeContrastVector LMinusMContrastVector MelanopsinContrastVector];
            elseif strcmp(stimuli(stimulus), 'Melanopsin')
                intendedContrastVector = MelanopsinContrastVector;
                splatterVectors = [SConeContrastVector LMinusMContrastVector LMSContrastVector];
            end
            
            if min(intendedContrastVector*100) < 390
                yIntendedMin = min(intendedContrastVector*100) - 5;
                
            else
                yIntendedMin = 390;
            end
            if max(intendedContrastVector*100) > 410
                yIntendedMax = max(intendedContrastVector*100) + 5;
            else
                yIntendedMax = 410;
            end
            
            if min(splatterVectors*100) < -10
                ySplatterMin = min(splatterVectors*100) - 5;
                
            else
                ySplatterMin = -10;
            end
            if max(splatterVectors*100) > 10
                ySplatterMax = max(splatterVectors*100) + 5;
            else
                ySplatterMax = 10;
            end
            
            hold on;
            line([0.5 4.5], [350 350], 'Color', 'r', 'LineStyle', '--');
            line([0.5 4.5], [20 20], 'Color', 'r', 'LineStyle', '--');
            line([0.5 4.5], [-20 -20], 'Color', 'r', 'LineStyle', '--');
            
            ylim([ySplatterMin yIntendedMax]);
            
            %data = {100*SConeContrastVector, 100*LMinusMContrastVector, 100*LMSContrastVector, 100*MelanopsinContrastVector};
            %plotSpread(data,'xNames', {'S Cone', 'L-M', 'LMS', 'Melanopsin'}, 'distributionMarkers', {'o', 'o', 'o', 'o'});
            %breakyaxis([ySplatterMax yIntendedMin], 0.01, 0.1);
            
            
            
            data = horzcat({100*SConeContrastVector', 100*LMinusMContrastVector', 100*LMSContrastVector', 100*MelanopsinContrastVector'});
            
            if strcmp(p.Results.whichValidation, 'pre')
                catIdxInstance = zeros(1,5);
                catIdx = horzcat(catIdxInstance, catIdxInstance, catIdxInstance, catIdxInstance)';
                [test] = plotSpread(data, 'distributionMarkers', 'o', 'xNames', {'S Cone', 'L-M', 'LMS', 'Melanopsin'});
                text(0.25, (yIntendedMax+yIntendedMin)/2, sprintf('o: Pre-Experiment \n+: Post-Experiment'))
            elseif strcmp(p.Results.whichValidation, 'post')
                catIdxInstance = ones(1,5);
                catIdx = horzcat(catIdxInstance, catIdxInstance, catIdxInstance, catIdxInstance)';
                [test] = plotSpread(data, 'distributionMarkers', '+', 'xNames', {'S Cone', 'L-M', 'LMS', 'Melanopsin'});
                text(0.25, (yIntendedMax+yIntendedMin)/2, sprintf('o: Pre-Experiment \n+: Post-Experiment'))
            elseif strcmp(p.Results.whichValidation, 'combined')
                catIdxInstance = horzcat(zeros(1,5), ones(1,5));
                catIdx = horzcat(catIdxInstance, catIdxInstance, catIdxInstance, catIdxInstance)';
                [test] = plotSpread(data, 'categoryIdx', catIdx, 'categoryMarkers', {'o', '+'}, 'categoryLabels', {'Pre-Experiment', 'Post-Experiment'}, 'xNames', {'S Cone', 'L-M', 'LMS', 'Melanopsin'}, 'showMM', 3);
                text(0.25, (yIntendedMax+yIntendedMin)/2, sprintf('o: Pre-Experiment \n+: Post-Experiment'))
            end
            if yIntendedMin - ySplatterMax < 100
            else
                
                [test] = breakyaxis([ySplatterMax yIntendedMin], 0.01, 0.1);
            end
            
        end
    end
end


end % end function
