% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/');
subAnalysisDirectory = 'pupilPIPRAnalysis';

%% Determine which subjects pass inclusion/exclusion criteria for use in further analyses

[ goodSubjects, badSubjects ] = excludeSubjects(dropboxAnalysisDir);

fitTPUPCacheTag='TPUPParameters';
fitTPUPCacheHash='f4e5cca771b3eb2c431ac5d15ba81369';
fitTPUPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitTPUPCacheTag '_' fitTPUPCacheHash '.mat']);
load(fitTPUPCacheFileName);

simulationForPowerAnalysis(goodSubjects, TPUPParameters_bootstrapped)