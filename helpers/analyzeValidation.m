function [ passStatus, validation, medianMelanopsinBackgroundLuminance ] = analyzeValidation(subject, date, dropboxAnalysisDir, varargin)

% This function takes as input a particular session, specified by subject
% ID and date, and summarizes the validation results for that session. The
% code first finds where the relevant validation files live, reads in the
% textfiles outputted by the validation process, and compiles the
% validation results into a variable that can be saved as output. The
% routine will also determine if the particular session meets our
% inclusion/exclusion criteria, which for these PIPR experiments is <20%
% contrast for directions not of interest, and >350% contrast for the
% direction of interest (that is the median value of all validation
% measurements), and returns this as the variable passStatus. The routine
% can also display plots that summarize these validation results.

% The intended use case for this function is to examine an individual
% subject's validation results both before and after a session to make sure
% the session meets inclusion/exclusion criteria.

% Output:
%       - passStatus: this variable contains a logical determined by whether
%       this particular sesssion meetings inclusion criteria
%       - validation: this variable is a structure containing 4 subfields
%       pertaining to each stimulus type (Mel, LMS, Blue, and Red). Each
%       subfield is itself a structure, with distinct subfields for all
%       splatter measurements (Melanopsin, LMS, LMinusM, and S). The
%       subfield contains as many measurements as were specified (typically
%       10 total measurements for 5 pre-experiment, 5 post-experiment). 
%       - medianMelanopsinBackgroundLuminance: outputs the median value for
%       all validation measurements of the melanopsin background luminance
%       (note that all values will be saved within the validation
%       variable). This was useful when we were closely monitoring
%       melanopsin background luminance as a means of tracking overall
%       light output.

% Input (required):
%       -subject: the contents of this variable are a string that specifies
%       the subject ID ('MELA_0078', for example)
%       -date: the contents of this variable are a a string that specifies
%       the date of the session of interest, in MMDDYY format ('082417',
%       for example)
%       -dropboxAnalysisDir: the contents of this variable are a string
%       that specify where to look for the relevant results.
%           Note: for the PIPR experiment, validation results live within
%           the MELA_materials and MELA_materials_Through061317 so these
%           folders must be synced to the user's computer.

% Options:
%       -'whichValidation': a key-value pair to specify which validation
%       results to summarize. Options include 'pre' to only look for the
%       first 5 validation results, 'post' to look at only the last 5
%       validation results, or 'combined' to look at all ten validation
%       results. Essentially this input determines when we look at the
%       relevant validation session folder, which validation files are we
%       summarizing.
%       -'plot': a key-value pair to specify whether or not to display a
%       plot of the validation results. Options include 'on' or 'off'
%       -'verbose': a key-value pair to specify whether to display
%       potentially helpful information on the screen. Options include 'on'
%       or 'off'

% Example call:
%   [passStatus, validation, medianMelanopsinBackgroundLuminance] = analyzeValidation('MELA_0096', '092117', dropboxAnalysisDir, 'whichValidation', 'combined', 'plot', 'on')

%% Parse input
p = inputParser; p.KeepUnmatched = true;

p.addParameter('whichValidation','combined',@ischar);
p.addParameter('plot','on',@ischar);
p.addParameter('verbose','off',@ischar);


p.parse(varargin{:});

%% Figure out where the relevant session folder lives

% Where the validation files live depends on when the data was collected.
% Older sessions will be located within the MELA_materials_Through061317
% folder, while newer sessions are found within MELA_materials/Legacy
if exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials', 'Legacy', 'PIPRMaxPulse', date)), 'dir')
    subdir = '../MELA_materials/Legacy/PIPRMaxPulse';
elseif exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials_Through061317', 'PIPRMaxPulse', date)), 'dir')
    subdir = '../MELA_materials_Through061317/PIPRMaxPulse';
else
    sprintf('No Session Found for Given Date (%s)', date)
    return
end

% basedon the 'whichValidation' key-value pair, determine which validation
% measurements we care about. Basically later on we're going to find a
% folder which contains all of the validation results for the given
% session. Here is where we specify which of these validation files we care
% about.
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

%% Now start collecting the validation results
% This section ultimately compiles the validation output variable
stimuli = {'Melanopsin', 'LMS', 'Blue', 'Red'};

% set up a tracker for fail status. If at any point as we start collecting
% these validation results the session meets exclusion criteria, this
% variable will take on a value of 1
failStatus = 0;


for stimulus = 1:length(stimuli)
    
    % the name of the folder in which the validation results live depends
    % on the stimulus
    if strcmp(stimuli(stimulus), 'Melanopsin')
        validationFolder = ['Cache-MelanopsinDirectedSuperMaxMel_' subject '_' date];
        
    elseif strcmp(stimuli(stimulus), 'LMS')
        validationFolder = ['Cache-LMSDirectedSuperMaxLMS_' subject '_' date];
        
    elseif strcmp(stimuli(stimulus), 'Blue')
        validationFolder = ['Cache-PIPRBlue_' subject '_' date];
        
    elseif strcmp(stimuli(stimulus), 'Red')
        validationFolder = ['Cache-PIPRRed_' subject '_' date];
        
    end
    
    
    % within the relevant validation folder, list all of the contents
    availableValidations = dir(fullfile(dropboxAnalysisDir, subdir, date, validationFolder));
    
    % prune this list of things we don't care about (like .DS_Store, ., and
    % ..) so we're left with a list that's just the relevant validations
    availableValidations = availableValidations(arrayfun(@(x) x.name(1), availableValidations) ~='.'); % discard the . .. and .DSStore dirs
    
    % determine how many validation files there are that we could be
    % looking at
    numberValidations = size(availableValidations,1);
    
    % based on the inputted 'whichValidation', can we in fact analyze the
    % validation files we mean to? (as in make sure if I ask to look at the
    % combined 10 validation files but there's only 5 validation files
    % within the session folder, stop the function and display an error)
    if lastValidationIndex - firstValidationIndex+1 > numberValidations
        failStatus = failStatus + 1; % if we're trying to analyze more validation files than are available, that's a fail
        passStatus = 0;
        error(['Attempted to find ' num2str(lastValidationIndex - firstValidationIndex+1), ' validations, but only found ' num2str(numberValidations)]);
        return
        
    % assuming we can find all of the validation files we need, now we can start to look at some of the validation results    
    else
        if stimulus == 1;
            if strcmp(p.Results.verbose, 'on')
                % tell user what validation files we found to work on
                sprintf('Of %s total validations, analyzing validation files %s to %s', num2str(numberValidations), num2str(firstValidationIndex), num2str(lastValidationIndex))
            end
        end
        
        % the structure and content of the validation files are different
        % for silent substitution and PIPR stimuli. This if statement sets
        % the structure for what the validation file looks like and what
        % validation results to save out for melanopsin and LMS directed
        % stimuli
        if strcmp(stimuli(stimulus), 'Melanopsin') || strcmp(stimuli(stimulus), 'LMS')
            
            % loop over the relevant validation measurements
            for ii = firstValidationIndex:lastValidationIndex
                
                % find the relevant validation file
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.txt']);
                validationResultsFile = {validationResultsFile.name};
                fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
                
                % read in that validation file
                fileID = fopen(fullValidationResultsFile);
                textFileContents = textscan(fileID, '%s', 'Delimiter', '\n');
                fclose('all');
                
                % extract the relevant validation measurements form that
                % file
                
                % determine background luminance:
                key = 'Background luminance [cd/m2]: ';
                whichCell = find(~cellfun(@isempty, cellfun(@(x) strfind(x(1:30), key(1:30)), textFileContents{1}, 'UniformOutput', false)));
                if isempty(whichCell)
                    backgroundLuminance = NaN;
                else
                    backgroundLuminance = sscanf(textFileContents{1}{whichCell(1)}(1+length(key):end), '%g');
                end
              
                
         
                
               
                
                key = '- SConeTabulatedAbsorbance: contrast =';
                whichCell = find(~cellfun(@isempty, cellfun(@(x) strfind(x(1:30), key(1:30)), textFileContents{1}, 'UniformOutput', false)));
                if isempty(whichCell)
                    SConeContrast = NaN;
                else
                    SConeContrast = sscanf(textFileContents{1}{whichCell(end)}(1+length(key):end), '%g');
                end
                
                key = '- LConeTabulatedAbsorbance + MConeTabulatedAbsorbance + SConeTabulatedAbsorbance: contrast =';  
                whichCell = find(~cellfun(@isempty, cellfun(@(x) strfind(x(1:30), key(1:30)), textFileContents{1}, 'UniformOutput', false)));
                if isempty(whichCell)
                    LMSContrast = NaN;
                else
                    LMSContrast = sscanf(textFileContents{1}{whichCell(end)}(1+length(key):end), '%g');
                end
                
                key = '- LConeTabulatedAbsorbance - MConeTabulatedAbsorbance: contrast =';  
                whichCell = find(~cellfun(@isempty, cellfun(@(x) strfind(x(1:30), key(1:30)), textFileContents{1}, 'UniformOutput', false)));
                if isempty(whichCell)
                    LMinusMContrast = NaN;
                else
                    LMinusMContrast = sscanf(textFileContents{1}{whichCell(end)}(1+length(key):end), '%g');
                end
                
                key = '- Melanopsin: contrast =';  
                whichCell = find(~cellfun(@isempty, cellfun(@(x) strfind(x(1:24), key(1:24)), textFileContents{1}, 'UniformOutput', false)));
                if isempty(whichCell)
                    MelanopsinContrast = NaN;
                else
                    MelanopsinContrast = sscanf(textFileContents{1}{whichCell(end)}(1+length(key):end), '%g');
                end
                
                
                % save out these validation measurements
                validation.(stimuli{stimulus})(ii).SConeContrast = SConeContrast;
                validation.(stimuli{stimulus})(ii).LMinusMContrast = LMinusMContrast;
                validation.(stimuli{stimulus})(ii).LMSContrast = LMSContrast;
                validation.(stimuli{stimulus})(ii).MelanopsinContrast = MelanopsinContrast;
                validation.(stimuli{stimulus})(ii).backgroundLuminance = backgroundLuminance;
            end
        end
        
        % again the structure of the PIPR stimuli validation files is a bit
        % different, this if statement sets the structure for what to look
        % for
        if strcmp(stimuli(stimulus), 'Blue') || strcmp(stimuli(stimulus), 'Red')
            
            % loop over the relevant validation files
            for ii = firstValidationIndex:lastValidationIndex
                
                % find the relevant validation file
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.txt']);
                validationResultsFile = {validationResultsFile.name};
                fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
                
                % open and read-in the validation file
                fileID = fopen(fullValidationResultsFile);
                textFileContents = textscan(fileID, '%s', 'Delimiter', ' ');
                
                % save out the relevant validation result
                backgroundLuminance = str2num(textFileContents{1}{4});
                
                validation.(stimuli{stimulus})(ii).backgroundLuminance = backgroundLuminance;
            end
            
            % also have to extract the PIPR intensities from the validation
            % files
            for ii = firstValidationIndex:lastValidationIndex
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.mat']);
                validationResultsFile = {validationResultsFile.name};
                fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
                
                [retinalIrradiance] = calculateRetinalIrradiance(fullValidationResultsFile);
                validation.(stimuli{stimulus})(ii).retinalIrradiance = retinalIrradiance.log10SumIrradianceQuantaPerCm2Sec;
            end
        end
    end
end % end loop over stimuli

%% Determine if subject meets inclusion criteria
% From the contents of the validation results variable, determine if the
% given session meets inclusion/exclusion criteria. 

% For the PIPR study, inclusion/exclusion criteria were as follows:
%   - for directions not of interest: splatter contrast must be less than
%   20%
%   - for the direction of interest: contrast must be at least 350%
%   - this evaluation is performed on the median validation measurement
 
for stimulus = 1:length(stimuli)
    
    % first analyze the silent substitution validations
    if strcmp(stimuli(stimulus), 'LMS') || strcmp(stimuli(stimulus), 'Melanopsin')
        % compile all validation results into a vector to make it easier to
        % calculate median
        SConeContrastVector = cell2mat({validation.(stimuli{stimulus}).SConeContrast});
        LMSContrastVector = cell2mat({validation.(stimuli{stimulus}).LMSContrast});
        LMinusMContrastVector = cell2mat({validation.(stimuli{stimulus}).LMinusMContrast});
        MelanopsinContrastVector = cell2mat({validation.(stimuli{stimulus}).MelanopsinContrast});
        
        % for LMS stimuli, apply exclusion criteria
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
        
        % for melanopsin stimuli, apply the exlcusion criteria
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
% Note that this plotting function is over-engineered to flexibly show all validation measurements with a reasonable spread. That is much of the code that follows is involved in determining where the appropriate yLims should be so that we can clearly see all of the data points 
if strcmp(p.Results.plot, 'on')
  
    % make a big plot
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
            
            % for the direction of interest, the y axis will be bounded
            % between 390 and 410 unless any of the data points are outside
            % that range. in that case, extend the range from that data
            % point further by 5%
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
            
            % for directions not of interest, the y bounds will be set
            % between -10 and 10 again unless individual data points
            % require that range to be extended 
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
            
            % add lines to show the boundaries of our exclusion criteria
            line([0.5 4.5], [350 350], 'Color', 'r', 'LineStyle', '--');
            line([0.5 4.5], [20 20], 'Color', 'r', 'LineStyle', '--');
            line([0.5 4.5], [-20 -20], 'Color', 'r', 'LineStyle', '--');
            
            ylim([ySplatterMin yIntendedMax]);
            
           
            
            % putting the data together to work with the plotSpread
            % function
            data = horzcat({100*SConeContrastVector', 100*LMinusMContrastVector', 100*LMSContrastVector', 100*MelanopsinContrastVector'});
            
            % some flexibility with plotting depending on which validation
            % measurements we're looking at
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
                
                % apply y-axis break to more cleanly show all validation
                % measurements on 1 subplot
                [test] = breakyaxis([ySplatterMax yIntendedMin], 0.01, 0.1);
            end
            
        end
    end
end


end % end function
