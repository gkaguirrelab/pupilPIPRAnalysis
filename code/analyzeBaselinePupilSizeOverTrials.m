function [ resultStruct ] = analyzeBaselinePupilSizeOverTrials(goodSubjects, dropboxAnalysisDir)

normalizationWindowIndices = 1:50;
stimuli = {'Melanopsin', 'LMS', 'PIPR'};

for session = 1:3
    resultStruct{session}.Melanopsin = [];
    resultStruct{session}.LMS = [];
    resultStruct{session}.PIPR = [];
end


for session = 1:3
    for subject = 1:length(goodSubjects{session}.ID)
        for stimulus = 1:length(stimuli)
            trialData = [];
            
            if strcmp(stimuli{stimulus}, 'Melanopsin')
                csvPath = fullfile(dropboxAnalysisDir, 'Legacy', 'baselineSizePIPRMaxPulse_PulseMel', goodSubjects{session}.ID{subject}, goodSubjects{session}.date{subject}, [goodSubjects{session}.ID{subject}, '_PupilPulseData_MaxMel_TimeSeries.csv']);
            elseif strcmp(stimuli{stimulus}, 'LMS')
                csvPath = fullfile(dropboxAnalysisDir, 'Legacy', 'baselineSizePIPRMaxPulse_PulseLMS', goodSubjects{session}.ID{subject}, goodSubjects{session}.date{subject}, [goodSubjects{session}.ID{subject}, '_PupilPulseData_MaxLMS_TimeSeries.csv']);
            elseif strcmp(stimuli{stimulus}, 'PIPR')
                csvPath = fullfile(dropboxAnalysisDir, 'Legacy', 'baselineSizePIPRMaxPulse_PulsePIPR', goodSubjects{session}.ID{subject}, goodSubjects{session}.date{subject}, [goodSubjects{session}.ID{subject}, '_PupilPulseData_PIPR_TimeSeries.csv']);
            end
            
            trialData = importdata(csvPath);
            %trialData = cell2mat(textscan(fopen(csvPath),'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f'));
            
            for trial = 1:size(trialData,2)
                resultStruct{session}.(stimuli{stimulus})(subject, trial) = nanmean(trialData(normalizationWindowIndices, trial));
            end
            
        end
    end
end

if 0 == 1
% do some plotting
plotFig = figure;
title('Melanopsin Trials')

for session = 1:3
    ax{session} = subplot(1,3,session);
    title(['Session ' num2str(session)]);
    xlabel('Trial Number')
    ylabel('Pupil Diameter (mm)')
    
    
    errBar(1,:) = nanstd(resultStruct{session}.Melanopsin, [], 1)/sqrt((length(resultStruct{session}.Melanopsin(:,1))));
    errBar(2,:) = nanstd(resultStruct{session}.Melanopsin, [], 1)/sqrt((length(resultStruct{session}.Melanopsin(:,1))));
    
    
    shadedErrorBar(1:24, nanmean(resultStruct{session}.Melanopsin, 1), errBar, 'lineProps', 'b-o');
end

plotFig = figure;
title('LMS Trials')

for session = 1:3
    ax{session} = subplot(1,3,session);
    title(['Session ' num2str(session)]);
    xlabel('Trial Number')
    ylabel('Pupil Diameter (mm)')
    
    
    errBar(1,:) = nanstd(resultStruct{session}.LMS, [], 1)/sqrt((length(resultStruct{session}.LMS(:,1))));
    errBar(2,:) = nanstd(resultStruct{session}.LMS, [], 1)/sqrt((length(resultStruct{session}.LMS(:,1))));
    
    
    shadedErrorBar(1:24, nanmean(resultStruct{session}.LMS, 1), errBar, 'lineProps', 'b-o');
end


plotFig = figure;
title('PIPR Trials')

for session = 1:3
    ax{session} = subplot(1,3,session);
    title(['Session ' num2str(session)]);
    xlabel('Trial Number')
    ylabel('Pupil Diameter (mm)')
    
    
    errBar(1,:) = nanstd(resultStruct{session}.PIPR, [], 1)/sqrt((length(resultStruct{session}.PIPR(:,1))));
    errBar(2,:) = nanstd(resultStruct{session}.PIPR, [], 1)/sqrt((length(resultStruct{session}.PIPR(:,1))));
    
    
    shadedErrorBar(1:24, nanmean(resultStruct{session}.PIPR, 1), errBar, 'lineProps', 'b-o');
end
end
end