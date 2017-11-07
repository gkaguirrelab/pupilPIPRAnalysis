function plotTPUPFits(goodSubjects, averageResponsePerSubject, TPUPParameters, dropboxAnalysisDir, varargin)

% After fitting the TPUP model to individual subject responses, this
% function plots the model fit against the average response for that same
% subject.


p = inputParser; p.KeepUnmatched = true;
p.addRequired('goodSubjects',@iscell);
p.addRequired('averageResponsePerSubject',@iscell);
p.addRequired('TPUPParameters',@iscell);
p.addRequired('dropboxAnalysisDir',@ischar);
p.addParameter('outDir', 'pupilPIPRAnalysis/TPUP/modelFits/', @ischar);
p.addParameter('stimulusTimebase',0:20:13980,@isnumeric); % gives a 700 index long vector, corresponding to a 14 second trial sampled each 20 milliseconds
p.addParameter('stimulusStepOnset',1000,@isnumeric); % in ms
p.addParameter('stimulusStepOffset',4000,@isnumeric); % in ms
p.addParameter('stimulusRampDuration',500,@isnumeric); % in ms
p.addParameter('initialValuesToSample',[-100, 0] ,@isnumeric);
p.addParameter('nInstances', 1 ,@isnumeric);


p.parse(goodSubjects, averageResponsePerSubject, TPUPParameters, dropboxAnalysisDir, varargin{:});


stimuli = {'LMS', 'Mel', 'Blue', 'Red'};


temporalFit = tfeTPUP('verbosity','full');


% to show the model fits, we're going to be computing the response based on
% the inputted TPUP parameters. Here we're getting some stuff ready to
% compute the modeled response

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


for session = 1:length(goodSubjects)
    for ss = 1:length(goodSubjects{session}.ID)
        for stimulus = 1:length(stimuli)
            outDir = fullfile(dropboxAnalysisDir, p.Results.outDir, stimuli{stimulus}, num2str(session));
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            
            plotFig = figure;
            hold on
            
            % first plot the subject average response
            plot(p.Results.stimulusTimebase, averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:)*100)
            
            % make the TPUP fit
            params0 = temporalFit.defaultParams;
            params0.paramMainMatrix(1) = TPUPParameters{session}.(stimuli{stimulus}).delay(ss);
            params0.paramMainMatrix(2) = TPUPParameters{session}.(stimuli{stimulus}).gammaTau(ss);
            params0.paramMainMatrix(3) = TPUPParameters{session}.(stimuli{stimulus}).exponentialTau(ss);
            params0.paramMainMatrix(4) = TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude(ss);
            params0.paramMainMatrix(5) = TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude(ss);
            params0.paramMainMatrix(6) = TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss);
            
            % now compute the TPUP model
            modelResponseStruct = temporalFit.computeResponse(params0, stimulusStruct, []);
            
            % plot it on top of the model fit
            plot(p.Results.stimulusTimebase, modelResponseStruct.values)
            
            % add some text to summarize fit params
            xlabel('Time (s)')
            ylabel('Pupil Diameter (% Change)')
            legend('Data', 'TPUP Fit')
            xlims=get(gca,'xlim');
            ylims=get(gca,'ylim');
            xrange = xlims(2)-xlims(1);
            yrange = ylims(2) - ylims(1);
            xpos = xlims(1)+0.75*xrange;
            ypos = ylims(1)+0.20*yrange;
            mdl = fitlm(averageResponsePerSubject{session}.(stimuli{stimulus})(ss,:)*100, modelResponseStruct.values);
            rSquared = mdl.Rsquared.Ordinary;
            
            string = (sprintf(['Delay: ', num2str(params0.paramMainMatrix(1)), '\nGamma Tau: ', num2str(params0.paramMainMatrix(2)), '\nExponential Tau: ', num2str(params0.paramMainMatrix(3)), '\n\nTransient: ', num2str(params0.paramMainMatrix(4)), '\nSustained: ', num2str(params0.paramMainMatrix(5)), '\nPersistent: ', num2str(params0.paramMainMatrix(6)), '\nR2: ', num2str(rSquared)]));
            text(xpos, ypos, string)
            title(goodSubjects{session}.ID(ss));
            
            
            
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions

end % end function