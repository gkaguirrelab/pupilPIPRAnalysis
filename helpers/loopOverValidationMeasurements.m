stimuli = {'Melanopsin', 'LMS'};
for session = 1:3
    for stimulus = 1:length(stimuli)
        luminanceStruct{session}.(stimuli{stimulus}) = [];
        chromaticityStruct{session}.(stimuli{stimulus}) = [];
        
    end
end



firstValidationIndex = 1;
lastValidationIndex = 10;

for session = 1:3
    for ss = 1:length(goodSubjects{session}.ID)
        subject = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        if exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials', 'Legacy', 'PIPRMaxPulse', date)), 'dir')
            subdir = '../MELA_materials/Legacy/PIPRMaxPulse';
        elseif exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials_Through061317', 'PIPRMaxPulse', date)), 'dir')
            subdir = '../MELA_materials_Through061317/PIPRMaxPulse';
        else
            sprintf('No Session Found for Given Date (%s)', date)
            return
        end
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
            
            availableValidations = dir(fullfile(dropboxAnalysisDir, subdir, date, validationFolder));
            
            % prune this list of things we don't care about (like .DS_Store, ., and
            % ..) so we're left with a list that's just the relevant validations
            availableValidations = availableValidations(arrayfun(@(x) x.name(1), availableValidations) ~='.'); % discard the . .. and .DSStore dirs
            
            % determine how many validation files there are that we could be
            % looking at
            numberValidations = size(availableValidations,1);
            
            luminance = [];
            for ii = firstValidationIndex:lastValidationIndex
                
                % find the relevant validation file
                validationResultsFile = dir([fullfile(dropboxAnalysisDir, subdir, date, validationFolder, availableValidations(ii).name) '/*.mat']);
                test = load([validationResultsFile.folder, '/', validationResultsFile.name]);
                
                spectrum = test.cals{1}.modulationBGMeas.meas.pr650.spectrum;
                S = test.cals{1}.modulationBGMeas.meas.pr650.S;
                luminance(ii) = calculateLuminance(spectrum, S, 'photopic');
                
                load T_xyzCIEPhys10
                S = [380 2 201];
                T_xyz = SplineCmf(S_xyzCIEPhys10,683*T_xyzCIEPhys10,S);
                chromaticity = T_xyz(1:2,:)*spectrum/sum(T_xyz*spectrum);
                chromaticityAccumulator(ii,1) = chromaticity(1);
                chromaticityAccumulator(ii,2) = chromaticity(2);
                
                load T_xyz1931
                T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
    
                
                
            end
            luminanceStruct{session}.(stimuli{stimulus})(end+1) = median(luminance);
            chromaticityStruct{session}.(stimuli{stimulus})(ss,1) = median(chromaticityAccumulator(:,1));
            chromaticityStruct{session}.(stimuli{stimulus})(ss,2) = median(chromaticityAccumulator(:,2));
            
            
        end
    end
end