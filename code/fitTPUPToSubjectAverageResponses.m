function [ TPUPParameters ] = fitTPUPToSubjectAverageResponses(goodSubjects, averageResponsePerSubject, dropboxAnalysisDir, varargin)
% fitTPUPToSubjectAverageResponses
%
% DESCRIPTION OF ROUTINE
%
%
%
% INPUTS:
%
%
% OUTPUTS:
%
%
% OPTIONS:
%


%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('goodSubjects',@iscell);
p.addRequired('averageResponsePerSubject',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);

% Optional display and I/O params
p.addParameter('verbose',true,@islogical);
p.addParameter('makePlots',true,@islogical);

% Optional analysis parameters
p.addParameter('stimulusLabels',{'LMS' 'Mel' 'Blue' 'Red'},@iscell);
p.addParameter('lbTPUPbyStimulus',[-500, 150, 1, -400, -400, -400; ...
                                   -500, 150, 1, -400, -400, -400; ...
                                   -500, 150, 1, -400, -400, -400; ...
                                   -500, 150, 1, -400, -400, -400],@isnumeric);
p.addParameter('ubTPUPbyStimulus',[0, 400, 20, 0, 0, 0; ...
                                   0, 400, 20, 0, 0, 0; ...
                                   0, 750, 20, 0, 0, 0; ...
                                   0, 750, 20, 0, 0, 0],@isnumeric);
p.addParameter('initialTemporalParameters',[-200, 350, 5],@isnumeric);           
p.addParameter('stimulusTimebase',0:20:13980,@isnumeric);
p.addParameter('stimulusStepOnset',1000,@isnumeric);
p.addParameter('stimulusStepOffset',4000,@isnumeric);
p.addParameter('stimulusRampDuration',500,@isnumeric);
p.addParameter('initialValuesToSample',[-100, 0] ,@isnumeric);
p.addParameter('nInstances', 1 ,@isnumeric);

%% Parse and check the parameters
p.parse(goodSubjects, averageResponsePerSubject, dropboxAnalysisDir, varargin{:});


% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instance.
defaultParamsInfo.nInstances = p.Results.nInstances;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

% build up common parts of the packet
[stimulusStruct] =  makeStepPulseStimulusStruct(p.Results.stimulusTimebase, ...
                                                p.Results.stimulusStepOnset, ...
                                                p.Results.stimulusStepOffset, ...
                                                'rampDuration', p.Results.stimulusRampDuration);
thePacket.stimulus = stimulusStruct; % add stimulusStruct to the packet
thePacket.response.timebase = p.Results.stimulusTimebase;
thePacket.kernel = [];
thePacket.metaData = [];

%% now fit each subject
for session = 1:length(goodSubjects)
    for ss = 1:length(goodSubjects{session}.ID)
        for stimulus = 1:length(p.Results.stimulusLabels)
            
            
            
            rSquaredPooled = []; % for each subject, for each condition, we want to look at the R2 values of each fit
            for initialTransient = 1:2
                for initialSustained = 1:2
                    for initialPersistent = 1:2
                        % build the packet
                        initialValues = [p.Results.initialTemporalParameters, p.Results.initialValuesToSample(initialTransient), p.Results.initialValuesToSample(initialSustained), p.Results.initialValuesToSample(initialPersistent)];
                        thePacket.response.values = averageResponsePerSubject{session}.(p.Results.stimulusLabels{stimulus})(ss,:)*100;
                        [paramsFit,fVal,modelResponseStruct] = ...
                            temporalFit.fitResponse(thePacket, ...
                            'defaultParamsInfo', defaultParamsInfo, ...
                            'vlb', p.Results.lbTPUPbyStimulus(stimulus,:), 'vub',p.Results.ubTPUPbyStimulus(stimulus,:),...
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
            bestInitialValues = [p.Results.initialTemporalParameters, p.Results.initialValuesToSample(index1), p.Results.initialValuesToSample(index2), p.Results.initialValuesToSample(index3)];
            
            % do the fit with the best initialValues
            thePacket.response.values = averageResponsePerSubject{session}.(p.Results.stimulusLabels{stimulus})(ss,:)*100;
            [paramsFit,fVal,modelResponseStruct] = ...
                temporalFit.fitResponse(thePacket, ...
                'defaultParamsInfo', defaultParamsInfo, ...
                'vlb', p.Results.lbTPUPbyStimulus(stimulus,:), 'vub',p.Results.ubTPUPbyStimulus(stimulus,:),...
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
            
            outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/TPUP/modelFits/', p.Results.stimulusLabels{stimulus}, num2str(session));
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            saveas(plotFig, fullfile(outDir, [goodSubjects{session}.ID{ss}, '.png']), 'png');
            close(plotFig)
            
            % also save out the summary statistics of the model fit
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).transientAmplitude(ss) = paramsFit.paramMainMatrix(4);
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).sustainedAmplitude(ss) = paramsFit.paramMainMatrix(5);
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).persistentAmplitude(ss) = paramsFit.paramMainMatrix(6);
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).delay(ss) = paramsFit.paramMainMatrix(1);
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).gammaTau(ss) = paramsFit.paramMainMatrix(2);
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).exponentialTau(ss) = paramsFit.paramMainMatrix(3);
            TPUPParameters{session}.(p.Results.stimulusLabels{stimulus}).rSquared(ss) = rSquared;
            
            
            
            
            
        end % end loop over stimuli
        
        
    end % end loop over subjects
end % end loop over sessions




end % end function