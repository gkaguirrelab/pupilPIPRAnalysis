%% Setup basic variables

% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/');
subAnalysisDirectory = 'pupilPIPRAnalysis';

verbose = true;

%% Determine which subjects pass inclusion/exclusion criteria for use in further analyses
[ goodSubjects, badSubjects ] = excludeSubjects(dropboxAnalysisDir);
if verbose
    fprintf('Identified these good subjects:\n');
    goodSubjects{1}
    goodSubjects{2}
    goodSubjects{3}
    fprintf('Identified these bad subjects:\n');
    badSubjects
end


%% Set-up cache behavior
% Define cache and analysis behavior.

packetCacheBehavior='load';
packetCacheTag='averageResponses';
packetCacheHash='1dba149dca5ca39db2642e937ca641a4'; % averageResponsePerSubject format, 20 session 3 subjects
%packetCacheHash='4b0b8c2b7796ea46066526628594be72';%  averageResponsePerSubject format, 16 session 3 subjects
%packetCacheHash='bb16f8bf6378d5d9c4d17a974ce8b50a'; %  averageResponsePerSubject format
%packetCacheHash='33d1c25008a78f521ec22d5ac8b90c45';

fitIAMPCacheBehavior='load';
fitIAMPCacheTag='IAMPParameters';
fitIAMPCacheHash='9ad20e4e5b8620e1320bccf30524950a'; % amplitudesPerSubject format, with 1,000,000 bootstrap iterations
%itIAMPCacheHash='c7ef9027bab0d773ab5749be36a4c543'; % BAD -- amplitudesPerSubject format, with 1,000,000 bootstrap iterations, 16 session 3 subjects
%fitIAMPCacheHash='35cddbf0e2e521c995e61a42f068a57b'; % BAD -- amplitudesPerSubject format, with 1,000,000 bootstrap iterations
%fitIAMPCacheHash='6419bead30977ae08fac174c0add6050'; % BAD -- amplitudesPerSubject format, with 10,000 bootstrap iterations
%fitIAMPCacheHash='606c239b41195df378b4d3adfb92d4f8'; % with 1,000,000 bootstrap iterations
%fitIAMPCacheHash='73004795a6ed72b2a7d0125f0d717346'; % with 100,000 bootstrap iterations
%fitIAMPCacheHash='1cb86f142cea0cac341ada71fdc3e4e0'; % with 10,000 bootstrap iterations
%fitIAMPCacheHash='b895c664ae7fb3385f4be0ff75f99dd3'; % with 1000 bootstrap iterations
%fitIAMPCacheHash='2c0fb7a2620551afe8d3a0849b368685'; % with 100 bootstrap iterations

fitTPUPCacheBehavior='load';
fitTPUPCacheTag='TPUPParameters';
fitTPUPCacheHash='9a509f623f277c16ac330a05c9499091'; % TPUPParameter format, maxGamma 750 for blue/red, 400 for mel/lms; 20 session 3 subjects
%fitTPUPCacheHash='71a1232f88f36a9d4fe50b27b2eeec82'; % TPUPParamter format, maxGamma 750
%fitTPUPCacheHash='3e8657fda425c1ff57c7eb9c939efef5'; % TPUPParameter format, maxGamma 400
%fitTPUPCacheHash='328e576af3d9b937571b2166a7d44753'; % TPUPParameter format, maxGamma 600
%fitTPUPCacheHash='55b8bafaf8ac5a164a0bf4060418a8ff'; % with extended gamma range (150-700)


%% Create or load the packetCellArray
% The variable averageResponsePerSubject is a 3 x 1 cell array, with the
% first dimension corresponding to the data from the three sessions. Each
% cell contains a structure. The fields include 'LMS','Mel,'Blue','Red',
% and each of these fields contains a m x n matrix, where m is the number
% of subjects and n is the number of timepoints in the response.
%
% The 'make' case not only assembles the packets, but also creates figures
% that are saved in the directory 'dataOverview/averageResponse' within the
% dropboxAnalysisDir.
switch packetCacheBehavior
    case 'make'  % If we are not to load the cache, then we must generate it
        % Make the average responses. 
        [ averageResponsePerSubject, groupAverageResponse ] = makeAverageResponse(goodSubjects, dropboxAnalysisDir);
        % calculate the hex MD5 hash for the packetCellArray
        packetCacheHash = DataHash(averageResponsePerSubject);
        % Set path to the packetCache and save it using the MD5 hash name
        packetCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [packetCacheTag '_' packetCacheHash '.mat']);
        save(packetCacheFileName, 'averageResponsePerSubject', 'groupAverageResponse', '-v7.3');
        fprintf(['Saved the ' packetCacheTag ' with hash ID ' packetCacheHash '\n']);
    case 'load'  % load a cached packetCellArray
        fprintf('>> Loading cached packetCellArray\n');
        packetCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [packetCacheTag '_' packetCacheHash '.mat']);
        load(packetCacheFileName);
    otherwise
        error('Please define a legal packetCacheBehavior');
end

%% Fit IAMP model
% This routine models the pupil response for a given subject with the
% average response across subjects for that stimulus. The fitting is done
% on a per-trial basis and then the standard error of the mean of the
% across-trial amplitude is determined by bootstrap resampling.
%
% The 'make' case also creates figures that are saved in the directory
% 'IAMP/modelFits'
switch fitIAMPCacheBehavior    
    case 'make'
        [ amplitudesPerSubject ] = fitIAMPToSubjectTrialResponses(goodSubjects, averageResponsePerSubject, groupAverageResponse, dropboxAnalysisDir);
        % calculate the hex MD5 hash for the amplitudes result
        fitIAMPCacheHash = DataHash(amplitudesPerSubject);        
        % Set path to the packetCache and save it using the MD5 hash name
        fitIAMPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitIAMPCacheTag '_' fitIAMPCacheHash '.mat']);
        save(fitIAMPCacheFileName,'amplitudesPerSubject','-v7.3');
        fprintf(['Saved the ' fitIAMPCacheTag ' with hash ID ' fitIAMPCacheHash '\n']);        
    case 'load'  % load a cached amplitude and amplitudeSEM variable        
        fprintf(['>> Loading cached ' fitIAMPCacheTag ' \n']);
        fitIAMPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitIAMPCacheTag '_' fitIAMPCacheHash '.mat']);
        load(fitIAMPCacheFileName);        
    otherwise        
        error('Please define a legal packetCacheBehavior');
end

%% Fit TPUP model to avg packets
% 
% the 'make' case creates figures which are saved in the directory
% 'TPUP/modelFits'.

switch fitTPUPCacheBehavior    
    case 'make'
        [ TPUPParameters ] = fitTPUPToSubjectAverageResponses(goodSubjects, averageResponsePerSubject, dropboxAnalysisDir);
        % calculate the hex MD5 hash for the TPUP fits
        fitTPUPCacheHash = DataHash(TPUPParameters);        
        % Set path to the packetCache and save it using the MD5 hash name
        fitTPUPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitTPUPCacheTag '_' fitTPUPCacheHash '.mat']);
        save(fitTPUPCacheFileName,'TPUPParameters', '-v7.3');
        fprintf(['Saved the ' fitTPUPCacheTag ' with hash ID ' fitTPUPCacheHash '\n']);        
    case 'load'  % load a cached TPUP parameters        
        fprintf(['>> Loading cached ' fitTPUPCacheTag ' \n']);
        fitTPUPCacheFileName=fullfile(dropboxAnalysisDir, subAnalysisDirectory, 'cache', [fitTPUPCacheTag '_' fitTPUPCacheHash '.mat']);
        load(fitTPUPCacheFileName);        
    otherwise        
        error('Please define a legal packetCacheBehavior');
end


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


