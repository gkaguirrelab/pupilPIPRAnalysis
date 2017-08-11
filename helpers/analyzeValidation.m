function [ validation ] = analyzeValidation(subject, date, dropboxAnalysisDir, varargin)

% date option
% default is third session, but i need a way to look up other subjects
% by date (for my exclude subjecgts scripts

%% Parse input
%p = inputParser; p.KeepUnmatched = true;

%p.addParameter('date','noneSpecified',@ischar);

%p.parse(varargin{:});

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

%% Now start collecting the stats
% set up some variables
stimuli = {'Melanopsin', 'LMS', 'Blue', 'Red'};
%validation.MelanopsinStimulation = [];
%validation.LMSStimulation = [];
%validation.BlueStimulation = [];
%validation.RedStimulation = [];


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
    
    if strcmp(stimuli(stimulus), 'Melanopsin') || strcmp(stimuli(stimulus), 'LMS')
        
        for ii = 1:10
            validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.txt']);
            validationResultsFile = {validationResultsFile.name};
            fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
            
            fileID = fopen(fullValidationResultsFile);
            textFileContents = textscan(fileID, '%s', 'Delimiter', ' ');
            
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
        
        for ii = 1:10
            validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.txt']);
            validationResultsFile = {validationResultsFile.name};
            fullValidationResultsFile = char(fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name, validationResultsFile));
            
            fileID = fopen(fullValidationResultsFile);
            textFileContents = textscan(fileID, '%s', 'Delimiter', ' ');
            
            backgroundLuminance = str2num(textFileContents{1}{4});
            
            validation.(stimuli{stimulus})(ii).backgroundLuminance = backgroundLuminance;
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
        
        

%% plot to summarize results
for stimulus = 1:length(stimuli)
    if strcmp(stimuli(stimulus), 'LMS') || strcmp(stimuli(stimulus), 'Melanopsin')
        SConeContrastVector = cell2mat({validation.(stimuli{stimulus}).SConeContrast});
        LMSContrastVector = cell2mat({validation.(stimuli{stimulus}).LMSContrast});
        LMinusMContrastVector = cell2mat({validation.(stimuli{stimulus}).LMinusMContrast});
        MelanopsinContrastVector = cell2mat({validation.(stimuli{stimulus}).MelanopsinContrast});
        
        plotFig = figure;
        title(stimuli(stimulus))
        hold on
        
        
        onesVector = ones(1,length(SConeContrastVector));
        plot(ones, 100*SConeContrastVector, 'o', 'Color', 'k')
        plot(2*ones, 100*LMSContrastVector, 'o', 'Color', 'k')
        plot(3*ones, 100*LMinusMContrastVector, 'o', 'Color', 'k')
        plot(4*ones, 100*MelanopsinContrastVector, 'o', 'Color', 'k')
        
        set(gca,'XTick',1:4);
        set(gca,'XTickLabel',{'S Cone' 'LMS' 'L-M' 'Melanopsin'});
        xlim([0.5 4.5])
        xlabel('Contrast Type')
        ylabel('Contrast (%)')
        
    end
end


end % end function
