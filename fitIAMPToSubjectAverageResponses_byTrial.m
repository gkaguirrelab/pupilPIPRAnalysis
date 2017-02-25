function [ amplitudes, amplitudesSEM ] = fitIAMPToSubjectAverageResponses_byTrial(goodSubjects, piprCombined, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir)

% The main output will be an [ss x 3] matrix, called amplitude, which contains the results
% from fitting the IAMP model to to average responses per subject. The
% first column will be the amplitude of LMS stimulation, the second column
% melanopsin stimulation, the third column pipr stimulation

stimulusOrder = {'LMS' 'mel' 'blue' 'red'};

paramLockMatrix = [];
IAMPFitToData = [];

for session = 1:2;
    amplitudes{session} = [];
    amplitudesSEM{session} = [];
end

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeIAMP('verbosity','none');

% Create the kernel for each stimulation type. For the IAMP model, the
% kernel will be the average group response for each stimulation, scaled to
% 1
for session = 1:2;
    for timepoints = 1:length(averageLMSCombined{session});
        LMSKernel(1,timepoints) = nanmean(averageLMSCombined{1}(:,timepoints));
        MelKernel(1,timepoints) = nanmean(averageMelCombined{1}(:,timepoints));
        PIPRKernel(1,timepoints) = nanmean(piprCombined{1}(:,timepoints));
        BlueKernel(1,timepoints) = nanmean(averageBlueCombined{1}(:,timepoints));
        RedKernel(1,timepoints) = nanmean(averageRedCombined{1}(:,timepoints));
    end
    LMSKernel = LMSKernel/abs(min(LMSKernel));
    MelKernel = MelKernel/abs(min(MelKernel));
    PIPRKernel = PIPRKernel/abs(min(PIPRKernel));
    BlueKernel = BlueKernel/abs(min(BlueKernel));
    RedKernel = RedKernel/abs(min(RedKernel));
    
    % create the timebase: events are 14 s long, and we're sampling every 20
    % ms
    timebase = (1:length(averageLMSCombined{session}));
    
    % create stimulus profile -> has to be a blip with this
    % configuration of IAMP (it convolves the stimulus profile
    % with the kernel)
    stimulus.values = zeros(1,length(averageLMSCombined{session}));  % blip to be convolved with kernel; fixed per subject per contrast
    stimulus.values(1,1) = 1;
    stimulus.timebase = timebase;
    thePacket.stimulus = stimulus;
    
    for ss = 1:size(goodSubjects{session},1); % loop over subjects
        subject = goodSubjects{session}(ss,:);
        numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
        
        % determine the date of a session
        dateList = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        dateList = dateList(~ismember({dateList.name},{'.','..', '.DS_Store'}));
        
        if numberSessions == 1;
            date = dateList(1).name;
        end
        if numberSessions == 2;
            if session == 1;
                date = dateList(2).name;
            elseif session == 2;
                date = dateList(1).name;
            end
        end
        
        for stimulation = 1:length(stimulusOrder);
            if stimulation == 1; % LMS condition
                kernel.values = LMSKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseLMS', subject, date, [subject, '_PupilPulseData_MaxLMS_TimeSeries.csv']));
                
            elseif stimulation == 2; % mel condition
                kernel.values = MelKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseMel', subject, date, [subject, '_PupilPulseData_MaxMel_TimeSeries.csv']));
            elseif stimulation == 3; % blue condition
                kernel.values = BlueKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
            elseif stimulation == 4; % red condition
                kernel.values = RedKernel;
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
                
            end
            
            % finish kernel assembly
            kernel.timebase = timebase;
            thePacket.kernel = kernel;
            
            % create packet metaData
            thePacket.metaData = [];
            
            % determine number of trials
            numberOfTrials = size(allTrials,2);
            
            packetCellArray = [];
            for trial = 1:numberOfTrials
                packetCellArray{trial} = [];
            end
            for trial = 1:numberOfTrials
                packetCellArray{trial} = thePacket;
                if sum(isnan(allTrials(:,trial))) ~= 700;
                    packetCellArray{trial}.response.values = allTrials(:,trial)';
                    packetCellArray{trial}.response.timebase = timebase;
                else
                    packetCellArray{trial} = [];
                    
                end
            end
            
            packetCellArray = packetCellArray(~cellfun('isempty',packetCellArray));
            
            
            for trial = 1:length(packetCellArray)
                % do the actual fitting via IAMP
                
                [paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(packetCellArray{trial}, 'defaultParamsInfo', defaultParamsInfo,'paramLockMatrix',paramLockMatrix);
                stimulusAmplitudes(trial) = paramsFit.paramMainMatrix;
            end
            amplitudes{session}(ss,stimulation) = mean(stimulusAmplitudes);
            amplitudesSEM{session}(ss,stimulation) = nanstd(stimulusAmplitudes)/sqrt((length(stimulusAmplitudes)));
            %if stimulation == 3;
            %figure; plot(thePacket.response.values); hold on; plot(modelResponseStruct.values); paramsFit.paramMainMatrix
            % end
        end
    end
    
    %% do some plotting to summarize the results
    
    %plot correlation of LMS and Mel
    plotFig = figure;
    x = amplitudes{session}(:,1)*100;
    y = amplitudes{session}(:,2)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    plot(amplitudes{session}(:,1)*100,amplitudes{session}(:,2)*100, 'o')
    xlabel('LMS Amplitude (%)')
    ylabel('Mel Amplitude (%)')
    r = corr2(amplitudes{session}(:,1), amplitudes{session}(:,2));
    legend(['r = ', num2str(r)])
    hold on
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateLMSxMel.png']), 'png');
    close(plotFig);
    
    % plot correlation of Mel and PIPR
    plotFig = figure;
    x = ((amplitudes{session}(:,3)*100)-(amplitudes{session}(:,4)*100));
    y = amplitudes{session}(:,2)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    plot(((amplitudes{session}(:,3)*100)-(amplitudes{session}(:,4)*100)),amplitudes{session}(:,2)*100, 'o')
    xlabel('PIPR Amplitude (%)')
    ylabel('Mel Amplitude (%)')
    r = corr2(((amplitudes{session}(:,3))-(amplitudes{session}(:,4))), amplitudes{session}(:,2));
    legend(['r = ', num2str(r)])
    hold on
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateMelxPIPR.png']), 'png');
    close(plotFig);
    
    % plot correlation of PIPR and LMS
    plotFig = figure;
    y = amplitudes{session}(:,1)*100;
    x = ((amplitudes{session}(:,3)*100)-(amplitudes{session}(:,4)*100));
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    plot(((amplitudes{session}(:,3)*100)-(amplitudes{session}(:,4)*100)), amplitudes{session}(:,1)*100, 'o')
    ylabel('LMS Amplitude (%)')
    xlabel('PIPR Amplitude (%)')
    r = corr2(((amplitudes{session}(:,3))-(amplitudes{session}(:,4))), amplitudes{session}(:,1));
    legend(['r = ', num2str(r)])
    hold on
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateLMSxPIPR.png']), 'png');
    close(plotFig);
    
    % plot correlation of blue and red
    plotFig = figure;
    x = amplitudes{session}(:,3)*100;
    y = amplitudes{session}(:,4)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    plot(amplitudes{session}(:,3)*100,amplitudes{session}(:,4)*100, 'o')
    xlabel('Blue Amplitude (%)')
    ylabel('Red Amplitude (%)')
    r = corr2(amplitudes{session}(:,3), amplitudes{session}(:,4));
    legend(['r = ', num2str(r)])
    hold on
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateBluexRed.png']), 'png');
    close(plotFig);
    
    % plot correlation of [blue + red] and [LMS + mel]
    plotFig = figure;
    x = (amplitudes{session}(:,3)+amplitudes{session}(:,4))/2*100;
    y = (amplitudes{session}(:,2)+amplitudes{session}(:,1))/2*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    plot((amplitudes{session}(:,3)+amplitudes{session}(:,4))/2*100,(amplitudes{session}(:,2)+amplitudes{session}(:,1))/2*100, 'o')
    xlabel('Blue+Red Amplitude (%)')
    ylabel('LMS+Mel Amplitude (%)')
    r = corr2((amplitudes{session}(:,3)+amplitudes{session}(:,4))/2,(amplitudes{session}(:,2)+amplitudes{session}(:,1))/2);
    legend(['r = ', num2str(r)])
    hold on
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    
    axis square
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateBlueRedxMelLMS.png']), 'png');
    close(plotFig);
    
    % plot correlation of [blue/red] and [mel/lms]
    x=[];
    y=[];
    plotFig = figure;
    for tt = 1:length(amplitudes{session}(:,4))
        x(tt) = amplitudes{session}(tt,3)/amplitudes{session}(tt,4);
        y(tt) = (amplitudes{session}(tt,2)/amplitudes{session}(tt,1));
    end
    %x = (amplitudes{session}(:,4)/amplitudes{session}(:,5))*100;
    %y = (amplitudes{session}(:,2)/amplitudes{session}(:,1))*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    plot(x, y, 'o')
    xlabel('Blue/Red Amplitude')
    ylabel('Mel/LMS Amplitude')
    r = corr2(x, y);
    legend(['r = ', num2str(r)])
    hold on
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/AverageResponse', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateBlueToRedxMelToLMS.png']), 'png');
    close(plotFig);
end % end loop over sessions

end % end function