%% Setup basic variables
% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/');
subAnalysisDirectory = 'PIPRMaxPulse_PulsePIPR';


%% Determine which subjects pass inclusion/exclusion criteria for use in further analyses

[ goodSubjects ] = excludeSubjects()

%% Determine average response in each subject to PIPR, melanopsin-directed, 
%% and LMS-directed stimulation

[piprCombined, averageMelCombined, averageLMSCombined, averageBlueCombined, averageRedCombined] = plotPIPRResponse(goodSubjects, dropboxAnalysisDir)

%% Determine amplitude of verage response in each subject to PIPR, melanopsin-directed, 
%% and LMS-directed stimulation

[ amplitudes ] = fitIAMPToSubjectAverageResponses(goodSubjects, piprCombined, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir)