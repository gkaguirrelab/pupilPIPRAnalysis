function [ TPUPParameters ] = fitTPUPToSubjectAverageResponses(goodSubjects, averageResponsePerSubject, dropboxAnalysisDir, varargin)
% fitTPUPToSubjectAverageResponses
%
% This function fits the average response of each subject to each stimulus
% to our TPUP model, which attempts to quantify the temporal dynamics of
% the pupil response. The model breaks the pupil response into three
% temporally distinct components: a transient component intended to capture
% the initial constriction event that rapidly decays, a sustained component
% that lasts for the duration of the light step, and a persistent component
% that controls the slower return to baseline after light-offset.
% Essentially the model functions by scaling these different parameters and
% summing them to recreate the pupil response. Note that the model intends
% to capture temporal dynamics of the system, and each component does not
% directly correspond to any particular biological mechanism. For further
% illustration of what the model looks like in practice, see Spitschan et
% al., PNAS (in revision).


% The model relies on 3 temporal parameters and 3 amplitude parameters. The
% 3 temporal parameters include: delay (shifts the pupil response in time
% relative to the onset of the light pulse), gamma tau (all three amplitude
% components are convolved with a gamma kernel controlled by this
% parameter; the same gamma tau is applied to all three temporal
% components), and exponential tau (which controls the rate at which the
% persistent component returns to baseline). The amplitude parameters
% function to scale each amplitude component.
%
%
%
% INPUTS:
%       - goodSubjects: list of subjects and associated dates when they
%           were studied. The model will attempt to fit the average
%           response for each subject found within this variable to each
%           stimulus (the goodSubjects variable must
%       - averageResponsePerSubject: a results variable that contains the
%           average response from every subject to each stimulus type. The
%           variable averageResponsePerSubject is a 1x3 cell array, with
%           each cell corresponding to a different session. The content of
%           each cell array is a structure, with subfields referring to the
%           stimulus (as well as for the standard error of the mean for
%           that stimulus). The contents of each subfield is a matrix, with
%           each row referring to a different subject. Each column is a
%           timepoint containing the average pupil diameter in units %
%           change.
%       - dropboxAnalysisDir: location of the directory where we can find
%           the data
%
% OUTPUTS:
%       - TPUPParameters: the contents of this variable is a 1x3 cell
%           array, with each cell corresponding to a session. The contents
%           of each cell is a structure, with different subfields
%           corresponding to the different stimuli (LMS, Mel, Blue, and
%           Red). Each subfield is itself a structure, with subfields
%           including each TPUP parameter (delay, gamma tau, exponential
%           tau, transient amplitude, sustained amplitude, and persistent
%           amplitude) . The contents of each subfield is a vector, with
%           each index along that vector corresponding to the results for
%           an individual subject in the same order as found in
%           goodSubjects{session}.ID.
%
%
% OPTIONS:
%       - 'verbose': options for the key-value pair include the logicals
%       true and false, and
%           determine whether additional information is returned to the
%           terminal.
%       - 'makePlots': options for the key-value pair include the logicals
%           true and false, and control whether plots of the average
%           response and their model fits are presented and saved.
%       - 'stimulusLabels': a list of all stimuli presented to subjects as
%           part of the experiment, consisting of LMS, Mel, Blue, and Red.
%           Also controls the behavior of one of the main loops in the code
%           below (for each subject, loop over every stimulus type and do
%           the fit on the average response).
%       -'lbTPUPbyStimulus': an 4 x 6 matrix where 4 refers to the number
%           of stimuli (consistent with the number in stimulusLabels) and 6
%           corresponds to each parameter of the TPUP model. The lower
%           bounds are the same for all stimulus types. Note that the
%           specification of delay is a little odd because of the negative
%           value; a negative value is interpreted by the model to shift
%           the response later in time relative to light-onset.
%       -'ubTPUPbyStimulus': an 4 x 6 matrix where 4 refers to the number
%           of stimuli (consistent with the number in stimulusLabels) and 6
%           corresponds to each parameter of the TPUP model. This became
%           important to specify per stimuli because we have learned that
%           the model fits to silent substitution stimuli are better with
%           the max gamma tau of 400, while the PIPR stimuli are best fit
%           when the gamma tau is allowed to extend to 750.
%       -'initialTemporalParameters': a 1x3 vector with each value
%           corresponding to one of the temporal parameters, delay, gamma
%           tau, and exponential tau in that order. These values were
%           chosen because they create a sensible pupil response to serve
%           as a starting point.
%       -'stimulusTimebase': controls the timebase used to create the
%           stimulus profile that goes into each packet for fitting. This
%           variable also controls the response.timebase packet subfield as
%           well. For these experiments, each trial is 14 seconds long and
%           sampled every 20 ms (0:20:13980)
%       -'stimulusOnset': specifies when the step pulse begins within each
%           trial. Default is set to 1000 ms after the trial begins
%       -'stimulusOffset': specifies when the step pulse ends within each
%           trial. Default is set to 4000 ms after the trial begins
%       -'stimulusRampDuration': determines length of time for the
%           half-cosine ramp-on, ramp-off of the stimulus step pulse
%       -'initialValuesToSample': in implementing the model, we learned
%           that the model fit depends on what the starting values for each
%           amplitude component are. We adopted the approach that we would
%           perform a separate fit where the starting value for each
%           amplitude parameter is 0 or -100. We would then determien which
%           set of starting values produces the best fit as determined by
%           the rSquared value, and then call this fit our final fit.
%       -'nInstances': determine how many stimuli are presented to a
%           subject as part of one packet. Here, one packet is just the
%           response to one stimulus.
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

% order of parameters is: delay, gamma tau, exponential tau, transient
% amplitude, sustained amplitude, and persistent amplitude.
% Each row corresponds to the bounds to use for each stimulus type, in the
% same order specified in 'stimulusLabels' above
p.addParameter('lbTPUPbyStimulus',[-500, 150, 1, -400, -400, -400; ... % LMS
                                   -500, 150, 1, -400, -400, -400; ... % Mel
                                   -500, 150, 1, -400, -400, -400; ... % Blue
                                   -500, 150, 1, -400, -400, -400],@isnumeric); % Red
p.addParameter('ubTPUPbyStimulus',[0, 400, 20, 0, 0, 0; ... % LMS
                                   0, 400, 20, 0, 0, 0; ... % Mel
                                   0, 750, 20, 0, 0, 0; ... % Blue
                                   0, 750, 20, 0, 0, 0],@isnumeric); % Red
                               
                               
p.addParameter('initialTemporalParameters',[-200, 350, 5],@isnumeric);    % delay, gamma tau, exponential tau       
p.addParameter('stimulusTimebase',0:20:13980,@isnumeric); % gives a 700 index long vector, corresponding to a 14 second trial sampled each 20 milliseconds
p.addParameter('stimulusStepOnset',1000,@isnumeric); % in ms
p.addParameter('stimulusStepOffset',4000,@isnumeric); % in ms
p.addParameter('stimulusRampDuration',500,@isnumeric); % in ms
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
% make the stimulus profile
[stimulusStruct] =  makeStepPulseStimulusStruct(p.Results.stimulusTimebase, ...
                                                p.Results.stimulusStepOnset, ...
                                                p.Results.stimulusStepOffset, ...
                                                'rampDuration', p.Results.stimulusRampDuration);
thePacket.stimulus = stimulusStruct; % add stimulusStruct to the packet

% create the timebase for the response subfield, which is the same as that
% used for the stimulus timebase
thePacket.response.timebase = p.Results.stimulusTimebase;
% TPUP model requires no kernel
thePacket.kernel = [];
% TPUP model also requires no metaData
thePacket.metaData = [];

%% Fit the TPUP model to the average response of each subject to each stimulus type
for session = 1:length(goodSubjects) % loop over sessions
    for ss = 1:length(goodSubjects{session}.ID) % loop over subjects
        for stimulus = 1:length(p.Results.stimulusLabels) % loop over stimuli
            
            
            
            rSquaredPooled = []; % for each subject, for each condition, we want to look at the R2 values of each fit
            
            % this series of loops allows us to perform a series of model fits to the same response where
            % we vary each initial amplitude value as either 0 or -100.
            % From this series of fits, we determine which starting values
            % give the best fit, and then call that set our final fit
            for initialTransient = 1:2
                for initialSustained = 1:2
                    for initialPersistent = 1:2
                        
                        % finish the packet construction by adding the
                        % response.values subfield
                        thePacket.response.values = averageResponsePerSubject{session}.(p.Results.stimulusLabels{stimulus})(ss,:)*100;
                        
                        % assign initial values for the fit. The temporal
                        % parameters are defined by the inputParser, and to
                        % these we add either a 0 or -100 to each amplitude
                        % parameter
                        initialValues = [p.Results.initialTemporalParameters, p.Results.initialValuesToSample(initialTransient), p.Results.initialValuesToSample(initialSustained), p.Results.initialValuesToSample(initialPersistent)];
                        
                        % actually do the fit
                        [paramsFit,fVal,modelResponseStruct] = ...
                            temporalFit.fitResponse(thePacket, ...
                            'defaultParamsInfo', defaultParamsInfo, ...
                            'vlb', p.Results.lbTPUPbyStimulus(stimulus,:), ...
                            'vub',p.Results.ubTPUPbyStimulus(stimulus,:),...
                            'initialValues',initialValues,...
                            'fminconAlgorithm','sqp'...
                            );
                        
                        % determine the rSquared of the fit
                        mdl = fitlm(thePacket.response.values, modelResponseStruct.values);
                        rSquared = mdl.Rsquared.Ordinary;
                        
                        % save the rSquared for each fit with the different
                        % starting values so we can determine which was
                        % best
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
                'vlb', p.Results.lbTPUPbyStimulus(stimulus,:), ...
                'vub',p.Results.ubTPUPbyStimulus(stimulus,:),...
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
            
            % add text to the plot that summarizes the TPUP parameters of
            % the fit
            string = (sprintf(['Delay: ', num2str(paramsFit.paramMainMatrix(1)), '\nGamma Tau: ', num2str(paramsFit.paramMainMatrix(2)), '\nExponential Tau: ', num2str(paramsFit.paramMainMatrix(3)), '\n\nTransient: ', num2str(paramsFit.paramMainMatrix(4)), '\nSustained: ', num2str(paramsFit.paramMainMatrix(5)), '\nPersistent: ', num2str(paramsFit.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            title(goodSubjects{session}.ID(ss));
            
            % save out the plot
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