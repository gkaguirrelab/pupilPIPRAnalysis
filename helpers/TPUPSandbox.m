% the TPUP model continues to struggle to fit some of the mel responses. In
% particular, the model frequently returns fits where the transient (and
% frequently the sustained) amplitudes are 0, making the fit entirely out
% of the persistent component
% This script is intended to demonstrate this problem. First a general
% packet for TPUP model fitting is created. Then we fit the model to two
% represented subjects (MELA_0074 and MELA_0077 from the first session)

%% load basic variables
% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/');
subAnalysisDirectory = 'pupilPIPRAnalysis';
packetCacheTag='averageResponses';
packetCacheHash='33d1c25008a78f521ec22d5ac8b90c45';

%% Set up the basic packet
% make stimulus structure
timebase = 0:20:13980; % in msec
stepOnset = 1000; % in msec
stepOffset = 4000; % in msec
[stimulusStruct] = makeStepPulseStimulusStruct(timebase, stepOnset, stepOffset, 'rampDuration', 500);
thePacket.stimulus = stimulusStruct; % add stimulusStruct to the packet

% set up the rest of the packet
thePacket.kernel = [];
thePacket.metaData = []; % both elements are needed to make a complete packet, but both won't change the fit

% set up other general TPUP parameters
defaultParamsInfo.nInstances = 1;
temporalFit = tfeTPUP('verbosity','full'); % Construct the model object

%%


%% first look at fit with one representative subject
% this subject, MELA_0074 from session 1, was chosen because despite having
% reasonable data quality, the TPUP fit is poor, especially in its
% inability to fit a transient component to where it looks like a transient
% piece ought to go

% first load up that data
packetCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [packetCacheTag '_' packetCacheHash '.mat']);
load(packetCacheFileName);

% load up the subject list
[ goodSubjects, badSubjects ] = excludeSubjects(dropboxAnalysisDir);

% determine subject index of the relevant subject
for ss = 1:1:size(goodSubjects{1}{1},1)
    if goodSubjects{1}{1}(ss,:) == 'MELA_0074'
        subjectIndex = ss;
    end
end

thePacket.response.values = 100*averageMelCombined{1}(subjectIndex,:); % subject index 11 from the first session corresponds to MELA_0074
% one additional note is that not multiplying by 100 produces an
% entirely different fit
thePacket.response.timebase = timebase; % same as the stimulus struct

% now do the fit
vlb=[-500, 150, 1, -2000, -2000, -2000]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right)
vub=[0, 750, 30, 0, 0, 0];
[paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo, 'vlb', vlb, 'vub',vub);

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
title('MELA_0074');

%% one more example subject
% subject MELA_0077 from the first session also fails to fit any transient
% piece

% determine the relevant subject index
for ss = 1:1:size(goodSubjects{1}{1},1)
    if goodSubjects{1}{1}(ss,:) == 'MELA_0077'
        subjectIndex = ss;
    end
end

thePacket.response.values = 100*averageMelCombined{1}(subjectIndex,:); % subject index 11 from the first session corresponds to MELA_0074
% one additional note is that not multiplying by 100 produces an
% entirely different fit
thePacket.response.timebase = timebase; % same as the stimulus struct

% now do the fit
vlb=[-500, 150, 1, -2000, -2000, -2000]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right)
vub=[0, 750, 30, 0, 0, 0];
[paramsFit,fVal,modelResponseStruct] = temporalFit.fitResponse(thePacket, 'defaultParamsInfo', defaultParamsInfo, 'vlb', vlb, 'vub',vub);

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
title('MELA_0077');