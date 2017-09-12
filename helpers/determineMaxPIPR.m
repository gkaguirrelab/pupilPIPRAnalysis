function [ maximumBluePIPRIntensity ] = determineMaxPIPR(observerAgeInYears, theCalType)


%% Standard parameters
params.experiment = 'PIPRMaxPulse';
params.experimentSuffix = 'PIPRMaxPulse';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 6;
params.isActive = 1;
params.useAmbient = 1;
params.OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRBlue';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 475;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.85; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];


baseDir = fileparts(fileparts(which('OLMakePIPR')));
configDir = fullfile(baseDir, 'config', 'stimuli');
cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');

cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName, [], getpref('OneLight', 'OneLightCalData'));
assert(~isempty(cal), 'OLFlickerComputeModulationSpectra:NoCalFile', 'Could not load calibration file: %s', ...
    OLCalibrationTypes.(params.calibrationType).CalFileName);
calID = OLGetCalID(cal);

lambda = 0.001;
spd1 = OLMakeMonochromaticSpd(cal, params.peakWavelengthNm, params.fwhmNm);
[maxSpd1, scaleFactor1] = OLFindMaxSpectrum(cal, spd1, lambda);

% Find the primaries for that
primary0 = OLSpdToPrimary(cal, maxSpd1, 'lambda', lambda);
backgroundPrimary = zeros(size(primary0));


S = cal.describe.S;     % Photoreceptors
B_primary = cal.computed.pr650M;

lensTransmit = LensTransmittance(S, 'Human', 'CIE', observerAgeInYears, params.pupilDiameterMm);
macTransmit = MacularTransmittance(S, 'Human', 'CIE', params.fieldSizeDegrees);

%% Calculate the intensity
radianceWattsPerM2Sr = (B_primary * primary0) .* lensTransmit' .* macTransmit';
pupilAreaMm2 = pi*((params.pupilDiameterMm/2)^2);
eyeLengthMm = 17;
irradianceWattsPerUm2 = RadianceToRetIrradiance(radianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
irradianceQuantaPerUm2Sec = EnergyToQuanta(S,irradianceWattsPerUm2);
irradianceQuantaPerCm2Sec = (10.^8)*irradianceQuantaPerUm2Sec;
irradianceQuantaPerCm2SecMax = irradianceQuantaPerCm2Sec;

scalar = 10^params.filteredRetinalIrradianceLogPhotons / sum(irradianceQuantaPerCm2Sec);
    
    % Cap at 1
    if scalar > 1
        scalar = 1;
    end
    
    primary1 = scalar*primary0;

radianceWattsPerM2Sr = (B_primary * primary1) .* lensTransmit' .* macTransmit';
irradianceWattsPerUm2 = RadianceToRetIrradiance(radianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
irradianceQuantaPerUm2Sec = EnergyToQuanta(S,irradianceWattsPerUm2);
irradianceQuantaPerCm2Sec = (10.^8)*irradianceQuantaPerUm2Sec;

maximumBluePIPRIntensity = log10(sum(irradianceQuantaPerCm2SecMax));