function [ stimulusStruct ] = makeStepPulseStimulusStruct(timebase, pulseOnset, pulseOffset, varargin)

% Make a step pulse stimulus structure
%
%   Usage:
%       [stimulusStruct] = makeStepPulseStimulusStruct(timebase,
%       pulseOnset, pulseOffset, varargin)
%
%   Inputs:
%       timebase: vector of timepoints (e.g. timebase = 0:20:13980)
%       pulseOnset: timepoint when the step pulse begins (same units as the
%           timebase)
%       pulseOffset: timepoint when the step pulse ends (same units as the
%           timebase)
%       rampDuration (optional): a key-value pair to specify duration of a
%       half-cosine ramp on and off for the stimulus structure (e.g.
%       'rampDuration', 500)
%
%   Outputs:
%       stimulusStruct.timebase: vector of timepoints (equivalent to
%       timebase input)
%       stimulusStruct.values: vector of stimulus values (maximum of 1
%       during pulse step)
%  
%   Written by Harry McAdams, August 2017

% parse the inputs
p = inputParser; p.KeepUnmatched = true;

p.addParameter('rampDuration',0,@isnumeric);

p.parse(varargin{:});


% specify the stimulus timebase
deltaT = timebase(2) - timebase(1); % in msecs
totalTime = timebase(length(timebase))+deltaT; % in msecs
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

% Specify the stimulus struct.
% We create here a step function of neural activity, with half-cosine ramps
%  on and off
stepOnset=pulseOnset; % msecs
stepDuration=pulseOffset-pulseOnset; % msecs
rampDuration=p.Results.rampDuration; % msecs

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

end % end function