function [ retinalIrradiance ] = calculateRetinalIrradiance(validationFile, date)

% The purpose of this function is to load up an individual validation file
% and extract the retinal irradiance of the stimulus. The meat of this code
% was written by Manuel Spitschan, I (HMM) amd just packaging it up for my
% purposes

%% Load the file
tmp = load(validationFile);

% Extract the wavelength sampling spec and turn into a wavelength vector
S = tmp.cals{end}.modulationBGMeas.meas.pr650.S;
wls = SToWls(S);

% Extract the background spd and the modulation spd
bgSpd = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
modSpd = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;

% Plot them
% figure;
% plot(wls, bgSpd, '-k'); hold on;
% plot(wls, modSpd, '-b', 'LineWidth', 2);
% pbaspect([1 1 1]); set(gca, 'TickDir', 'out');
% xlabel('Wavelength'); ylabel('Radiance [mW/sr/cm-1/nm]');

%% (1) Calculate the properties of the light
pupilDiameterMm = 6;
out1 = CalculateLightProperties(S, modSpd, pupilDiameterMm);


%% (2) Now, filter the stimulus by the pre-receptoral filtering and do the calculations again
if datenum(date, 'mmddyy') > datenum('010517', 'mmddyy') 
    observerAgeInYears =  tmp.cals{end}.describe.OBSERVER_AGE;
else
    observerAgeInYears =  tmp.cals{end}.describe.REFERENCE_OBSERVER_AGE;
end
fieldSizeDeg = tmp.cals{end}.describe.cache.data(observerAgeInYears).describe.params.fieldSizeDegrees;
lensTransmit = LensTransmittance(S, 'Human', 'CIE', observerAgeInYears, pupilDiameterMm);
macTransmit = MacularTransmittance(S, 'Human', 'CIE', fieldSizeDeg);
modSpdFiltered = modSpd .* lensTransmit' .* macTransmit';

retinalIrradiance = CalculateLightProperties(S, modSpdFiltered, pupilDiameterMm);
end % end function