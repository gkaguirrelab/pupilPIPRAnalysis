function [ MelanopsinContrasts ] = calculateContrastForPIPRStimuli(goodSubjects, dropboxAnalysisDir)

for session = 1:3
    for ss = 1:length(goodSubjects{session}.ID)
        subjectID = goodSubjects{session}.ID{ss};
        date = goodSubjects{session}.date{ss};
        [ meanMelanopsinContrast ] = calculateContrastForPIPRStimuliPerSubject(subjectID, date, dropboxAnalysisDir);
        MelanopsinContrasts{session}(ss) = meanMelanopsinContrast;
    end
    
end




    function [ meanMelanopsinContrast ] = calculateContrastForPIPRStimuliPerSubject(subjectID, date, dropboxAnalysisDir)
        
        if exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials', 'Legacy', 'PIPRMaxPulse', date)), 'dir')
            subdir = '../MELA_materials/Legacy/PIPRMaxPulse';
        elseif exist(fullfile(fullfile(dropboxAnalysisDir, '..', 'MELA_materials_Through061317', 'PIPRMaxPulse', date)), 'dir')
            subdir = '../MELA_materials_Through061317/PIPRMaxPulse';
        else
            sprintf('No Session Found for Given Date (%s)', date)
            return
        end
        
        validationDirs = dir(fullfile(dropboxAnalysisDir, subdir, date, ['Cache-PIPRBlue_', subjectID, '_', date]));
        validationDirs = validationDirs(arrayfun(@(x) x.name(1), validationDirs) ~='.'); % discard the . .. and .DSStore dirs
        
        
        
        for mm = 1:10
            
            validationFile = dir(fullfile(dropboxAnalysisDir, subdir, date, ['Cache-PIPRBlue_', subjectID, '_', date], validationDirs(mm).name, ['Cache-PIPRBlue_', subjectID, '_', date, '*-SpotCheck.mat']));
            
            load(fullfile(dropboxAnalysisDir, subdir, date, ['Cache-PIPRBlue_', subjectID, '_', date], validationDirs(mm).name, validationFile.name));
            
            
            
            backgroundSpectrum = cals{1}.modulationAllMeas(1).meas.pr650.spectrum;
            stimulusSpectrum = cals{1}.modulationAllMeas(2).meas.pr650.spectrum;
            
            if isfield( cals{1}.describe.cache, 'OBSERVER_AGE')
                subjectAge = cals{1}.describe.cache.OBSERVER_AGE;
            else
                subjectAge = cals{1}.describe.cache.REFERENCE_OBSERVER_AGE;
            end
                
            T_receptors = cals{1}.describe.cache.data(subjectAge).describe.T_receptors;
            
            photoreceptorClasses = cals{1}.describe.cache.data(subjectAge).describe.photoreceptors;
            
            contrasts = (T_receptors*stimulusSpectrum-T_receptors*backgroundSpectrum)./(T_receptors*backgroundSpectrum);
            
            MelanopsinContrast(mm) = contrasts(4);
        end
        
        meanMelanopsinContrast = median(MelanopsinContrast);
        
    end


% plot to summarize
data = {MelanopsinContrasts{1}*100, MelanopsinContrasts{2}*100, MelanopsinContrasts{3}*100};
plotSpread(data, 'xNames', {'Session 1', 'Session 2', 'Session 3'}, 'showMM', 1);
ylabel('Melanopsin Contrast (%)')

end