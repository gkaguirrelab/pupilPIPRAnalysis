function [ effectivePIPR ] = determineEffectivePIPR(subject, date, dropboxAnalysisDir)

%% First determine which calibration

% for only third session
if datenum(date, 'mmddyy') < datenum('081617', 'mmddyy')
    calibrationType = 'BoxDLiquidShortCableCEyePiece2_ND02';
elseif datenum(date, 'mmddyy') >= datenum('081617', 'mmddyy') && datenum(date, 'mmddyy') < datenum('082517', 'mmddyy')
    calibrationType = 'BoxDLiquidShortCableCEyePiece2_ND01';
elseif datenum(date, 'mmddyy') >= datenum('082517', 'mmddyy')
    calibrationType = 'BoxDLiquidShortCableCEyePiece1_ND00';
end

%% Second determine subject's age
% this information can be found as part of the modulation file name for
% that subject
modulationFiles = dir([fullfile(dropboxAnalysisDir, '..', 'MELA_materials', 'Legacy/modulations', ['Modulation-PIPRMaxPulse-BackgroundPIPR_45sSegment-*_', subject, '_', date, '.mat'])]);

%% Load the file
tmp = load(fullfile('~/Desktop', 'Cache-PIPRBlue_MELA_0038_090817-BoxDLiquidShortCableCEyePiece1_ND00-SpotCheck.mat'));

% Extract the wavelength sampling spec and turn into a wavelength vector
S = tmp.cals{end}.modulationBGMeas.meas.pr650.S;
wls = SToWls(S);

% Extract the background spd and the modulation spd
bgSpd = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
modSpd = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;

% Plot them
figure;
plot(wls, bgSpd, '-k'); hold on;
plot(wls, modSpd, '-b', 'LineWidth', 2);
pbaspect([1 1 1]); set(gca, 'TickDir', 'out');
xlabel('Wavelength'); ylabel('Radiance [mW/sr/cm-1/nm]');

% (1) Calculate the properties of the light
pupilDiameterMm = 6;
out1 = CalculateLightProperties(S, modSpd, pupilDiameterMm);
PrintLightProperties(out1);

% (2) Now, filter the stimulus by the pre-receptoral filtering and do the calculations again
observerAgeInYears =  tmp.cals{end}.describe.OBSERVER_AGE;
fieldSizeDeg = tmp.cals{end}.describe.cache.data(observerAgeInYears).describe.params.fieldSizeDegrees;
lensTransmit = LensTransmittance(S, 'Human', 'CIE', observerAgeInYears, pupilDiameterMm);
macTransmit = MacularTransmittance(S, 'Human', 'CIE', fieldSizeDeg);
modSpdFiltered = modSpd .* lensTransmit' .* macTransmit';

out1 = CalculateLightProperties(S, modSpdFiltered, pupilDiameterMm);
PrintLightProperties(out1);

retinalIrradiance = out1.log10SumIrradianceQuantaPerCm2Sec;

end