function [ TPUPParameters ] = fitTPUPToSubjectAverageResponses(goodSubjects, averageResponsePerSubject, dropboxAnalysisDir)

% The main output will be an [ss x 3] matrix, called amplitude, which contains the results
% from fitting the IAMP model to to average responses per subject. The
% first column will be the amplitude of LMS stimulation, the second column
% melanopsin stimulation, the third column pipr stimulation

stimuli = {'LMS' 'Mel' 'Blue' 'Red'};

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

% set up boundaries for our fits
% although the boundaries are being coded here, the upper limit of the
% gamma tau will change depending on whether the stimulus is PIPR
% (blue/red) or silent substitution (mel/lms). This change will occur in
% the main loop.
vlb=[-500, 150, 1, -400, -400, -400]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, 400, 20, 0, 0, 0];
startingValues = [-100, 0];

% build up common parts of the packet
timebase = 0:20:13980; % in msec
stepOnset = 1000; % in msec
stepOffset = 4000; % in msec
[stimulusStruct] = makeStepPulseStimulusStruct(timebase, stepOnset, stepOffset, 'rampDuration', 500);
thePacket.stimulus = stimulusStruct; % add stimulusStruct to the packet
thePacket.response.timebase = timebase;
thePacket.kernel = [];
thePacket.metaData = [];

%% now fit each subject
for session = 1:length(goodSubjects)
    for ss = 1:length(goodSubjects{session}.ID)
        for stimulus = 1:length(stimuli)
            
            % from looking at the quality of fits, we've shown that the
            % PIPR stimuli are better fit when we allow the gamma to extend
            % up to 750. For the silent substitution stimuli, the fit is
            % better when the max gamma is 400
            if strcmp(stimuli{stimulus}, 'Mel') || strcmp(stimuli{stimulus}, 'LMS')
                vub(2) = 400;
            elseif strcmp(stimuli{stimulus}, 'Blue') || strcmp(stimuli{stimulus}, 'Red')
                vub(2) = 750;
            end
            
            rSquaredPooled = []; % for each subject, for each condition, we want to look at the R2 values of each fit
            for initialTransient = 1:2
                for initialSustained = 1:2
                    for initialPersistent = 1:2
                        % build the packet
                        initialValues = [-200, 350, 5, startingValues(initialTransient), startingValues(initialSustained), startingValues(initialPersistent)];
                        
                        thePacket.response.values = averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:)*100;
                        [paramsFit,fVal,modelResponseStruct] = ...
                            temporalFit.fitResponse(thePacket, ...
                            'defaultParamsInfo', defaultParamsInfo, ...
                            'vlb', vlb, 'vub',vub,...
                            'initialValues',initialValues,...
                            'fminconAlgorithm','sqp'...
                            );
                        
                        mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
                        rSquared = mdl.Rsquared.Ordinary;
                        
                        rSquaredPooled(initialTransient, initialSustained, initialPersistent) = rSquared;
                    end
                end
            end
            % determine which configuration gave the best fit, judged by
            % rSquared value
            [maxValue, maxIndex] = max(rSquaredPooled(:));
            [index1, index2, index3] = ind2sub(size(rSquaredPooled), maxIndex);
            bestInitialValues = [-200, 350, 5, startingValues(index1), startingValues(index2), startingValues(index3)];
            
            % do the fit with the best initialValues
            thePacket.response.values = averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:)*100;
            [paramsFit,fVal,modelResponseStruct] = ...
                temporalFit.fitResponse(thePacket, ...
                'defaultParamsInfo', defaultParamsInfo, ...
                'vlb', vlb, 'vub',vub,...
                'initialValues',bestInitialValues,...
                'fminconAlgorithm','sqp'...
                );
            
            % plot to summarize the fit
            % now do some plotting to summarize
            plotFig = figure;
            hold on
            plot(thePacket.response.timebase, thePacket.response.values)
            plot(modelResponseStruct.timebase, modelResponseStruct.values)
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            legend('Data', 'TPUP Fit')
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.20*yrange;
            mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            
            string = (sprintf(['Delay: ', num2str(paramsFit.paramMainMatrix(1)), '\nGamma Tau: ', num2str(paramsFit.paramMainMatrix(2)), '\nExponential Tau: ', num2str(paramsFit.paramMainMatrix(3)), '\n\nTransient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            title(goodSubjects{session}.ID(ss));
            
            outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/modelFits/', stimuli{stimulus}, num2str(session));
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            saveas(plotFig, fullfile(outDir, [goodSubjects{session}.ID{ss}, '.png']), 'png');
            close(plotFig)
            
            % also save out the summary statistics of the model fit
            TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude(ss) = paramsFit.paramMainMatrix(4);
            TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude(ss) = paramsFit.paramMainMatrix(5);
            TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss) = paramsFit.paramMainMatrix(6);
            TPUPParameters{session}.(stimuli{stimulus}).delay(ss) = paramsFit.paramMainMatrix(1);
            TPUPParameters{session}.(stimuli{stimulus}).gammaTau(ss) = paramsFit.paramMainMatrix(2);
            TPUPParameters{session}.(stimuli{stimulus}).exponentialTau(ss) = paramsFit.paramMainMatrix(3);
            TPUPParameters{session}.(stimuli{stimulus}).rSquared(ss) = rSquared;
            
            
            
            
            
        end % end loop over stimuli
        
        
    end % end loop over subjects
end % end loop over sessions




end % end function