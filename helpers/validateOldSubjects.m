function [ validation ] = validateOldSubjects(subject, date, dropboxAnalysisDir, varargin)

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
        sprintf('Attempted to find %s validations, but only found %s', num2str(lastValidationIndex - firstValidationIndex+1), num2str(numberValidations));
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
            % get the photoreceptors for the validation
            validationOverview = load(fullfile(dropboxAnalysisDir, subdir, date, [validationFolder, '.mat']));
            subfields = fields(validationOverview);
            validationOverview = validationOverview.(subfields{1}){1};
            described = [validationOverview.data.describe];
            T_receptors = described.T_receptors;
            
            
            % loop over the relevant validation measurements
            for ii = firstValidationIndex:lastValidationIndex
                
                % find the relevant validation file
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.mat']);
                validationFile = load([validationResultsFile.folder, '/', validationResultsFile.name]);
                
                modulationSpd = validationFile.cals{1}.modulationMaxMeas.meas.pr650.spectrum;
                backgroundSpd = validationFile.cals{1}.modulationBGMeas.meas.pr650.spectrum;
                
                % Calculate the contrasts
                backgroundReceptors = T_receptors*backgroundSpd;
                modulationReceptors = T_receptors*(modulationSpd-backgroundSpd);
                contrasts = modulationReceptors ./ backgroundReceptors;
                
                postreceptoralCombinations = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1];
                postreceptoralContrasts = postreceptoralCombinations' \ contrasts;
                validation.(stimuli{stimulus})(ii).LMSContrast = postreceptoralContrasts(1);
                validation.(stimuli{stimulus})(ii).LMinusMContrast = postreceptoralContrasts(2);
                validation.(stimuli{stimulus})(ii).SConeContrast = postreceptoralContrasts(3);
                validation.(stimuli{stimulus})(ii).MelanopsinContrast = postreceptoralContrasts(4);
                
            end
        end
    end
end


end % end loop over stimuli
