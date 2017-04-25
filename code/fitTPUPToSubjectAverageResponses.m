function [ TPUPAmplitudes, temporalParameters ] = fitTPUPToSubjectAverageResponses(goodSubjects, piprCombined, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir)

% The main output will be an [ss x 3] matrix, called amplitude, which contains the results
% from fitting the IAMP model to to average responses per subject. The
% first column will be the amplitude of LMS stimulation, the second column
% melanopsin stimulation, the third column pipr stimulation

stimulusOrder = {'LMS' 'mel' 'blue' 'red'};

paramLockMatrix = [];
IAMPFitToData = [];

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

%% do some plotting to summarize the results
% determine group averages
for session = 1:2;
    for timepoints = 1:length(averageBlueCombined{session});
        averageLMSCollapsed{session}(1,timepoints) = nanmean(averageLMSCombined{session}(:,timepoints));
        semLMSCollapsed{session}(1,timepoints) = nanstd(averageLMSCombined{session}(:,timepoints))/sqrt(size(averageLMSCombined{session},1));
        averageMelCollapsed{session}(1,timepoints) = nanmean(averageMelCombined{session}(:,timepoints));
        semMelCollapsed{session}(1,timepoints) = nanstd(averageMelCombined{session}(:,timepoints))/sqrt(size(averageMelCombined{session},1));
        averageBlueCollapsed{session}(1,timepoints) = nanmean(averageBlueCombined{session}(:,timepoints));
        semBlueCollapsed{session}(1,timepoints) = nanstd(averageBlueCombined{session}(:,timepoints))/sqrt(size(averageBlueCombined{session},1));
        averageRedCollapsed{session}(1,timepoints) = nanmean(averageRedCombined{session}(:,timepoints));
        semRedCollapsed{session}(1,timepoints) = nanstd(averageRedCombined{session}(:,timepoints))/sqrt(size(averageRedCombined{session},1));
        
        
    end
    
    
end

for session = 1:2;
    
    
    % assemble the packet
    % first create the stimulus structure
    
    % create the timebase: events are 14 s long, and we're sampling every 20
    % ms
    timebase = (0:20:13998);
    
    
    
    
    % Temporal domain of the stimulus
    deltaT = 20; % in msecs
    totalTime = 14000; % in msecs
    stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
    nTimeSamples = size(stimulusStruct.timebase,2);
    
    % Specify the stimulus struct.
    % We create here a step function of neural activity, with half-cosine ramps
    %  on and off
    stepOnset=1000; % msecs
    stepDuration=3000; % msecs
    rampDuration=500; % msecs
    
    % the square wave step
    stimulusStruct.values=zeros(1,nTimeSamples);
    stimulusStruct.values(round(stepOnset/deltaT): ...
        round(stepOnset/deltaT)+round(stepDuration/deltaT)-1)=1;
    % half cosine ramp on
    stimulusStruct.values(round(stepOnset/deltaT): ...
        round(stepOnset/deltaT)+round(rampDuration/deltaT)-1)= ...
        fliplr((cos(linspace(0,pi*2,round(rampDuration/deltaT))/2)+1)/2);
    % half cosine ramp off
    stimulusStruct.values(round(stepOnset/deltaT)+round(stepDuration/deltaT)-round(rampDuration/deltaT): ...
        round(stepOnset/deltaT)+round(stepDuration/deltaT)-1)= ...
        (cos(linspace(0,pi*2,round(rampDuration/deltaT))/2)+1)/2;
    thePacket.stimulus.values = stimulusStruct.values;
    thePacket.stimulus.timebase = timebase;
    
    % now kernel needed for tpup
    thePacket.kernel = [];
    for stimulation = 1:length(stimulusOrder)
        if stimulation == 1; % LMS condition
            outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseLMS/TPUP', num2str(session));
            
            result = averageLMSCollapsed{session};
            
        elseif stimulation == 2; % mel condition
            outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseMel/TPUP', num2str(session));
            
            result = averageMelCollapsed{session};
            
            
        elseif stimulation == 3; % blue condition
            outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
            
            result = averageBlueCollapsed{session};
        elseif stimulation == 4; % red condition
            outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
            
            result = averageRedCollapsed{session};
            
        end
        
        thePacket.response.timebase = timebase;
        thePacket.response.values = result*100;
        
        thePacket.metaData = [];
        
        
        initialValues=[200, 200, 10, -10, -25, -25];
        vlb=[-500, 100, 1, -2000, -2000, -2000];
        vub=[0, 500, 30, 0, 0, 0];
        
        % do the fitting on the group average data
        [paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo, 'initialValues', initialValues, 'vlb', vlb, 'vub',vub); % with
        %first three parameters fixed
        %[paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo,'paramLockMatrix',paramLockMatrix);
        
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        
        if stimulation == 1
            % save params for fitting individual subjects
            LMSParams{session} = paramsFit.paramMainMatrix;
            
            plotFig = figure;
            plot(timebase/1000, thePacket.response.values)
            hold on
            plot(timebase/1000, modelResponseStruct.values)
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            legend('Group Data', 'TPUP Fit')
            % determine variance explained
            mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            
            
            
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.15*yrange;
            
            string = (sprintf(['Transient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            saveas(plotFig, fullfile(outDir, ['groupAverage.png']), 'png');
            
            close(plotFig);
        elseif stimulation == 2
            % save params for fitting individual subjects
            MelParams{session} = paramsFit.paramMainMatrix;
            
            plotFig = figure;
            plot(timebase/1000, thePacket.response.values)
            hold on
            plot(timebase/1000, modelResponseStruct.values)
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            legend('Group Data', 'TPUP Fit')
            % determine variance explained
            mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            
            
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.15*yrange;
            
            string = (sprintf(['Transient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            saveas(plotFig, fullfile(outDir, ['groupAverage.png']), 'png');
            
            close(plotFig);
        elseif stimulation == 3
            % save params for fitting individual subjects
            blueParams{session} = paramsFit.paramMainMatrix;
            plotFig = figure;
            plot(timebase/1000, thePacket.response.values, 'Color', 'b')
            hold on
            plot(timebase/1000, modelResponseStruct.values, '-', 'Color', 'b')
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            % determine variance explained
            mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            
            
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.15*yrange;
            
            string = (sprintf(['Transient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            saveas(plotFig, fullfile(outDir, ['blueGroupAverage.png']), 'png');
            close(plotFig)
            
            
        elseif stimulation == 4
            % save params for fitting individual subjects
            redParams{session} = paramsFit.paramMainMatrix;
            plotFig = figure;
            plot(timebase/1000, thePacket.response.values, 'Color', 'r')
            hold on
            plot(timebase/1000, modelResponseStruct.values, '-', 'Color', 'r')
            % determine variance explained
            mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            
            
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            legend('Data', 'TPUP Fit')
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.15*yrange;
            
            string = (sprintf(['Transient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            saveas(plotFig, fullfile(outDir, ['redGroupAverage.png']), 'png');
            close(plotFig);
        end
    end
end

%% now fit each subject
for session = 1:2;
    for stimulation = 1:length(stimulusOrder)
        TPUPAmplitudes{session}{stimulation} = [];
        temporalParameters{session}{stimulation} = [];
        varianceExplained{session}{stimulation} = [];
    end
end




for session = 1:2;
    
    
    % assemble the packet
    % first create the stimulus structure
    
    % create the timebase: events are 14 s long, and we're sampling every 20
    % ms
    timebase = (0:20:13998);
    
    
    
    
    % Temporal domain of the stimulus
    deltaT = 20; % in msecs
    totalTime = 14000; % in msecs
    stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
    nTimeSamples = size(stimulusStruct.timebase,2);
    
    % Specify the stimulus struct.
    % We create here a step function of neural activity, with half-cosine ramps
    %  on and off
    stepOnset=1000; % msecs
    stepDuration=3000; % msecs
    rampDuration=500; % msecs
    
    % the square wave step
    stimulusStruct.values=zeros(1,nTimeSamples);
    stimulusStruct.values(round(stepOnset/deltaT): ...
        round(stepOnset/deltaT)+round(stepDuration/deltaT)-1)=1;
    % half cosine ramp on
    stimulusStruct.values(round(stepOnset/deltaT): ...
        round(stepOnset/deltaT)+round(rampDuration/deltaT)-1)= ...
        fliplr((cos(linspace(0,pi*2,round(rampDuration/deltaT))/2)+1)/2);
    % half cosine ramp off
    stimulusStruct.values(round(stepOnset/deltaT)+round(stepDuration/deltaT)-round(rampDuration/deltaT): ...
        round(stepOnset/deltaT)+round(stepDuration/deltaT)-1)= ...
        (cos(linspace(0,pi*2,round(rampDuration/deltaT))/2)+1)/2;
    thePacket.stimulus.values = stimulusStruct.values;
    thePacket.stimulus.timebase = timebase;
    
    % now kernel needed for tpup
    thePacket.kernel = [];
    
    for ss = 1:size(goodSubjects{session}{1},1) % loop over subjects
        subject = goodSubjects{session}{1}(ss,:);
        
        for stimulation = 1:length(stimulusOrder);
            if stimulation == 1; % LMS condition
                outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseLMS/TPUP', num2str(session));
                params = LMSParams;
                result = 100*averageLMSCombined{session}(ss, :);
                
            elseif stimulation == 2; % mel condition
                params = MelParams;
                outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulseMel/TPUP', num2str(session));
                
                result = 100*averageMelCombined{session}(ss, :);
                
                
            elseif stimulation == 3; % blue condition
                params = blueParams;
                outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
                
                result = 100*averageBlueCombined{session}(ss, :);
            elseif stimulation == 4; % red condition
                params = redParams;
                outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
                
                result = 100*averageRedCombined{session}(ss, :);
                
            end
            
            
            
            
            % create packet response values
            thePacket.response.values = result;
            thePacket.response.timebase = timebase;
            
            % create packet metaData
            thePacket.metaData = [];
            
            % Set some initial values
            %initialValues=[params{1}(1), params{1}(2), params{1}(3), -10, -25, -25];
            %vlb=[params{1}(1), params{1}(2), params{1}(3), -2000, -2000, -2000];
            %vub=[params{1}(1), params{1}(2), params{1}(3), 0, 0, 0];
            
            initialValues=[200, 200, 10, -10, -25, -25];
            vlb=[-500, 100, 1, -2000, -2000, -2000];
            vub=[0, 500, 30, 0, 0, 0];
            
            % do the actual fitting via TPUP
            [paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo, 'initialValues', initialValues, 'vlb', vlb, 'vub',vub);
            %[paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo);
            defaultVlb = [0 100 1 -2000 -2000 -2000];
            defaultVub = [500 350 30 0 0 0];
            
            TPUPAmplitudes{session}{stimulation}(ss,1) = paramsFit.paramMainMatrix(4);
            TPUPAmplitudes{session}{stimulation}(ss,2) = paramsFit.paramMainMatrix(5);
            TPUPAmplitudes{session}{stimulation}(ss,3) = paramsFit.paramMainMatrix(6);
            temporalParameters{session}{stimulation}(ss,1) = paramsFit.paramMainMatrix(1);
            temporalParameters{session}{stimulation}(ss,2) = paramsFit.paramMainMatrix(2);
            temporalParameters{session}{stimulation}(ss,3) = paramsFit.paramMainMatrix(3);
            
            for pp = 1:3;
                if paramsFit.paramMainMatrix(pp) == vlb(pp) || paramsFit.paramMainMatrix(pp) >= vub(pp)
                   
                    fprintf(['Subject: ', num2str(ss), ' Stimulation: ', stimulusOrder{stimulation}, ' Session: ', num2str(session), '\n Param ', num2str(pp), ': ', num2str(paramsFit.paramMainMatrix(pp)), '\n'])  
                end
            end
            
            % determine variance explained
            mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            varianceExplained{session}{stimulation}(ss,1) = rSquared;
            
            % save plot of model fits
            plotFig = figure;
            plot(thePacket.response.timebase/1000, thePacket.response.values)
            hold on
            plot(thePacket.response.timebase/1000, modelResponseStruct.values)
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            legend('Data', 'TPUP Fit')
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.15*yrange;
            
            string = (sprintf(['Transient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            
            
            
            
            
            saveas(plotFig, fullfile(outDir, [subject, '.png']), 'png');
            close(plotFig);
            
        end
    end
end



%% make a bar graph to compare relative contributions of each parameter to the final fit

for session = 1:2
    amplitudes = [];
    sem = [];
    for stimulus = 1:length(stimulusOrder)
        for measure = 1:3 % we have three measures of amplitude: transient, sustained, persistent as well as three temporal parameters
            amplitudes(measure,stimulus) = mean(TPUPAmplitudes{session}{stimulus}(:,measure));
            sem(measure,stimulus) = std(TPUPAmplitudes{session}{stimulus}(:,measure))/sqrt(length(TPUPAmplitudes{session}{stimulus}));
            meanTemporalParameters(measure,stimulus) = mean(temporalParameters{session}{stimulus}(:,measure));
            semTemporalParameters(measure,stimulus) = std(temporalParameters{session}{stimulus}(:,measure))/sqrt(length(temporalParameters{session}{stimulus}));

        end
    end
    
    
    plotFig = figure;
    
    b = barwitherr(sem, amplitudes);
    b(1).FaceColor = 'c';
    b(2).FaceColor = 'm';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Transient', 'Sustained', 'Persistent'})
    title('Mean TPUP Amplitudes')
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
    saveas(plotFig, fullfile(outDir, ['compareStimuli.png']), 'png');
    close(plotFig);
    
    
    % now compare the temporal parameters
    % first set the delay to positive
    for stimulus = 1:length(stimulusOrder)
        meanTemporalParameters(1,stimulus) = meanTemporalParameters(1,stimulus) * -1;
    end
    
    plotFig = figure;
    b = barwitherr(semTemporalParameters, meanTemporalParameters);
    b(1).FaceColor = 'c';
    b(2).FaceColor = 'm';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Delay', 'Gamma Tau', 'Exponential Tau'})
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'NorthEast')
    title('Mean Temporal Parameters')
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
    saveas(plotFig, fullfile(outDir, ['compareStimuli_temporalParameters.png']), 'png');
    close(plotFig);
    
    % now compare the median variance explained
    % first calculate the median variance for each stimulation
    for stimulus = 1:length(stimulusOrder)
        medianVarianceExplained(measure,stimulus) = median(varianceExplained{session}{stimulus}(:,1));
        iqrVarianceExplained(measure,stimulus) = iqr(varianceExplained{session}{stimulus}(:,1))
    end
    % now do the plotting
    plotFig = figure;
    b = barwitherr(1/2*iqrVarianceExplained, medianVarianceExplained);
    b(1).FaceColor = 'c';
    b(2).FaceColor = 'm';
    b(3).FaceColor = 'b';
    b(4).FaceColor = 'r';
    set(gca,'XTickLabel',{'Variance Explained'})
    legend('LMS', 'Mel', 'Blue', 'Red', 'Location', 'SouthWest')
    title('Median Variance Explained')
    outDir = fullfile(dropboxAnalysisDir,'PIPRMaxPulse_PulsePIPR/TPUP', num2str(session));
    saveas(plotFig, fullfile(outDir, ['compareStimuli_medianVarianceExplained.png']), 'png');
    close(plotFig);
end


end % end function