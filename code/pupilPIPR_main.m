%% Setup basic variables
% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/');
subAnalysisDirectory = 'pupilPIPRAnalysis';

%% Set-up cache behavior
% Define cache and analysis behavior.

packetCacheBehavior='load';
packetCacheTag='averageResponses';
packetCacheHash='33d1c25008a78f521ec22d5ac8b90c45';

fitIAMPCacheBehavior='load';
fitIAMPCacheTag='IAMPParameters';
fitIAMPCacheHash='b895c664ae7fb3385f4be0ff75f99dd3';

fitTPUPCacheBehavior='load';
fitTPUPCacheTag='TPUPParameters';
fitTPUPCacheHash='55b8bafaf8ac5a164a0bf4060418a8ff'; % with extended gamma range (150-700)


% Create or load the packetCellArray
switch packetCacheBehavior
    case 'make'  % If we are not to load the cache, then we must generate it
        % Make the average responses. 
        [piprCombined, averageMelCombined, averageLMSCombined, averageBlueCombined, averageRedCombined, semLMS, semMel, semBlue, semRed] = makeAverageResponse(goodSubjects, dropboxAnalysisDir);
        % calculate the hex MD5 hash for the packetCellArray
        packetCacheHash = DataHash(averageBlueCombined);
        % Set path to the packetCache and save it using the MD5 hash name
        packetCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [packetCacheTag '_' packetCacheHash '.mat']);
        save(packetCacheFileName, 'averageMelCombined', 'averageLMSCombined', 'averageBlueCombined', 'averageRedCombined', 'semLMS', 'semMel', 'semBlue', 'semRed','-v7.3');
        fprintf(['Saved the ' packetCacheTag ' with hash ID ' packetCacheHash '\n']);
    case 'load'  % load a cached packetCellArray
        fprintf('>> Loading cached packetCellArray\n');
        packetCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [packetCacheTag '_' packetCacheHash '.mat']);
        load(packetCacheFileName);
    otherwise
        error('Please define a legal packetCacheBehavior');
end

% Fit IAMP model to avg packets
switch fitIAMPCacheBehavior    
    case 'make'
        [ amplitudes, amplitudesSEM ] = fitIAMPToSubjectAverageResponses_byTrialBootstrap(goodSubjects, piprCombined, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir);
        % calculate the hex MD5 hash for the amplitudes result
        fitIAMPCacheHash = DataHash(amplitudes);        
        % Set path to the packetCache and save it using the MD5 hash name
        fitIAMPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitIAMPCacheTag '_' fitIAMPCacheHash '.mat']);
        save(fitIAMPCacheFileName,'amplitudes', 'amplitudesSEM','-v7.3');
        fprintf(['Saved the ' fitIAMPCacheTag ' with hash ID ' fitIAMPCacheHash '\n']);        
    case 'load'  % load a cached amplitude and amplitudeSEM variable        
        fprintf(['>> Loading cached ' fitIAMPCacheTag ' \n']);
        fitIAMPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitIAMPCacheTag '_' fitIAMPCacheHash '.mat']);
        load(fitIAMPCacheFileName);        
    otherwise        
        error('Please define a legal packetCacheBehavior');
end

% Fit TPUP model to avg packets
switch fitTPUPCacheBehavior    
    case 'make'
        [ TPUPAmplitudes, temporalParameters, varianceExplained ] = fitTPUPToSubjectAverageResponses(goodSubjects, piprCombined, averageMelCombined, averageLMSCombined, averageRedCombined, averageBlueCombined, dropboxAnalysisDir);
        % calculate the hex MD5 hash for the TPUP fits
        fitTPUPCacheHash = DataHash(TPUPAmplitudes);        
        % Set path to the packetCache and save it using the MD5 hash name
        fitTPUPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitTPUPCacheTag '_' fitTPUPCacheHash '.mat']);
        save(fitTPUPCacheFileName,'TPUPAmplitudes', 'temporalParameters', 'varianceExplained', '-v7.3');
        fprintf(['Saved the ' fitTPUPCacheTag ' with hash ID ' fitTPUPCacheHash '\n']);        
    case 'load'  % load a cached TPUP parameters        
        fprintf(['>> Loading cached ' fitTPUPCacheTag ' \n']);
        fitTPUPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitTPUPCacheTag '_' fitTPUPCacheHash '.mat']);
        load(fitTPUPCacheFileName);        
    otherwise        
        error('Please define a legal packetCacheBehavior');
end



%% Determine which subjects pass inclusion/exclusion criteria for use in further analyses

[ goodSubjects, badSubjects ] = excludeSubjects(dropboxAnalysisDir)

%% IAMP Analysis

% Examine correlation of response amplitudes across different stimulus
% conditions
acrossStimulusCorrelations(amplitudes, amplitudesSEM, dropboxAnalysisDir);

% Calculate PIPR, and examine relationship with other measures of
% melanopsin-driven pupil constriction (other calculations of the PIPR and
% pupil constriction elicited through silent substitution)
[ sustainedAmplitudes, pipr, netPipr ] = calculatePIPR(goodSubjects, amplitudes, amplitudesSEM, dropboxAnalysisDir)

% Determine test-retest reliability
[ rhoMel ] = acrossSessionCorrelation(goodSubjects, amplitudes, amplitudesSEM, dropboxAnalysisDir)
[trueRho] = determineMaximalCorrelation(amplitudesSEM, rhoMel, dropboxAnalysisDir)


%% TPUP Analysis
% First summarize results of the TPUP fits
summarizeTPUP(TPUPAmplitudes, temporalParameters, varianceExplained, dropboxAnalysisDir)

%% Summary plotting
% Create sparkline
plotSparkline(averageBlueCombined, averageLMSCombined, averageMelCombined, averageRedCombined, semBlue, semLMS, semMel, semRed, dropboxAnalysisDir)


