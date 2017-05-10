function [trueRho] = determineMaximalCorrelation(amplitudesSEM, rhoMel, dropboxAnalysisDir)



outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/IAMP/testRetest');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end





nSubjects = 25;



%% Create true test-retest
% first create test-retest results if the test-retest correlation was 1



% we want all of our subjects to have mel/lms ratios of between 0 and 1,
% which is largely what we're seeing with our data
melToLMSRange = [0 1];

% now divide nSubjects evenly along that range
deltaMelToLMS = (melToLMSRange(2) - melToLMSRange(1))/(nSubjects-1);
melToLMS = [];
% spread individual subjects along that range
for ss = 1:nSubjects
    melToLMS(ss) = 0+(ss-1)*deltaMelToLMS;
end
% simulate second session of data collection, here being identical to the
% first to provide perfect test-retest
melToLMS(2,:) = melToLMS(1,:);

% Now add noise to each simulated measurement
for nn = 1:1000
    
    
    
    
    for yy = 1:size(melToLMS,2)
        melToLMS(2,yy) = melToLMS(2,yy) + randn(1)/20;
    end
    
    rho(nn) = corr(melToLMS(1,:)', melToLMS(2,:)', 'type', 'Spearman');
    
    for ss = 1:nSubjects
        
        % now pick a random SEM from the variable amplitudesSEM
        randomIndex = randi([1 length(amplitudesSEM{1}(:,6))]);
        melToLMSWithMeasurementError(1,ss) = melToLMS(1, ss) + amplitudesSEM{1}(randomIndex,6).*randn(1);
        
        randomIndex = randi([1 length(amplitudesSEM{2}(:,6))]);
        melToLMSWithMeasurementError(2,ss) = melToLMS(2, ss) + amplitudesSEM{2}(randomIndex,6).*randn(1);
    end
    
    
    rhoWithMeasurementError(nn) = corr(melToLMSWithMeasurementError(1,:)', melToLMSWithMeasurementError(2,:)', 'type', 'Spearman');
    
    
end




plotFig = figure;
plot(rho, rhoWithMeasurementError, 'o')
hold on

x = rho;
y = rhoWithMeasurementError;
xnan = isnan(x);

xnanlist = [];
hits = 0;
for xx = 1:length(x);
    if xnan(xx) == 1;
        hits = hits+1;
        x(xx-(hits-1)) = [];
        y(xx-(hits-1)) = [];
        
    end
end
coeffs = polyfit(x, y, 1);
fittedX = linspace(min(x), 1, 1000);
fittedY = polyval(coeffs, fittedX);
plot(fittedX, fittedY, 'LineWidth', 3)
plot(fittedX, ones(length(fittedX),1)*0.56748, '-')
xlabel('True Rho')
ylabel('Observed Rho')
saveas(plotFig, fullfile(outDir, ['trueRhoxObservedRho1.png']), 'png');
close(plotFig);

% determine rho for the observed rhoWithMeasurementError

observedRhoWithMeasurementError = 0.56748;
for yy = 1:length(fittedY)
    if fittedY(yy) < observedRhoWithMeasurementError
        trueRho(1) = fittedX(yy);
    end
end




%% Method 2 for generating imperfect true correlations

for nn = 1:1000
    % we want all of our subjects to have mel/lms ratios of between 0 and 1,
    % which is largely what we're seeing with our data
    melToLMSRange = [0 1];
    
    % now divide nSubjects evenly along that range
    deltaMelToLMS = (melToLMSRange(2) - melToLMSRange(1))/(nSubjects-1);
    melToLMS = [];
    % spread individual subjects along that range
    for ss = 1:nSubjects
        melToLMS(ss) = 0+(ss-1)*deltaMelToLMS;
    end
    % simulate second session of data collection, here being identical to the
    % first to provide perfect test-retest
    melToLMS(2,:) = melToLMS(1,:);
    
    % Now add noise to each simulated measurement
    
    
    
    
    
    for yy = 1:size(melToLMS,2)
        melToLMS(2,yy) = melToLMS(2,yy) + randn(1);
    end
    
    rho(nn) = corr(melToLMS(1,:)', melToLMS(2,:)', 'type', 'Spearman');
    
    for ss = 1:nSubjects
        
        % now pick a random SEM from the variable amplitudesSEM
        randomIndex = randi([1 length(amplitudesSEM{1}(:,6))]);
        melToLMSWithMeasurementError(1,ss) = melToLMS(1, ss) + amplitudesSEM{1}(randomIndex,6).*randn(1);
        
        randomIndex = randi([1 length(amplitudesSEM{2}(:,6))]);
        melToLMSWithMeasurementError(2,ss) = melToLMS(2, ss) + amplitudesSEM{2}(randomIndex,6).*randn(1);
    end
    
    
    rhoWithMeasurementError(nn) = corr(melToLMSWithMeasurementError(1,:)', melToLMSWithMeasurementError(2,:)', 'type', 'Spearman');
    
    
end




plotFig = figure;
plot(rho, rhoWithMeasurementError, 'o')
hold on

x = rho;
y = rhoWithMeasurementError;
xnan = isnan(x);

xnanlist = [];
hits = 0;
for xx = 1:length(x);
    if xnan(xx) == 1;
        hits = hits+1;
        x(xx-(hits-1)) = [];
        y(xx-(hits-1)) = [];
        
    end
end
coeffs = polyfit(x, y, 1);
fittedX = linspace(min(x), 1, 1000);
fittedY = polyval(coeffs, fittedX);
plot(fittedX, fittedY, 'LineWidth', 3)
plot(fittedX, ones(length(fittedX),1)*0.56748, '-')

xlabel('True Rho')
ylabel('Observed Rho')
saveas(plotFig, fullfile(outDir, ['trueRhoxObservedRho2.png']), 'png');
close(plotFig);

% determine rho for the observed rhoWithMeasurementError

observedRhoWithMeasurementError = 0.56748;
for yy = 1:length(fittedY)
    if fittedY(yy) < observedRhoWithMeasurementError
        trueRho(2) = fittedX(yy);
    end
end

%% assuming perfect test-retest, what's the rank correlation if we consider within session noise?

melToLMSRange = [0 1];
rho = [];
    rhoWithMeasurementError = [];
for nn = 1:1000
    % now divide nSubjects evenly along that range
    deltaMelToLMS = (melToLMSRange(2) - melToLMSRange(1))/(nSubjects-1);
    melToLMS = [];
    
    % spread individual subjects along that range
    for ss = 1:nSubjects
        melToLMS(ss) = 0+(ss-1)*deltaMelToLMS;
    end
    % simulate second session of data collection, here being identical to the
    % first to provide perfect test-retest
    melToLMS(2,:) = melToLMS(1,:);
    
    rho(nn) = corr(melToLMS(1,:)', melToLMS(2,:)', 'type', 'Spearman');
    
    for ss = 1:nSubjects
        
        % now pick a random SEM from the variable amplitudesSEM
        randomIndex = randi([1 length(amplitudesSEM{1}(:,6))]);
        melToLMSWithMeasurementError(1,ss) = melToLMS(1, ss) + amplitudesSEM{1}(randomIndex,6).*randn(1);
        
        randomIndex = randi([1 length(amplitudesSEM{2}(:,6))]);
        melToLMSWithMeasurementError(2,ss) = melToLMS(2, ss) + amplitudesSEM{2}(randomIndex,6).*randn(1);
    end
    
    
    rhoWithMeasurementError(nn) = corr(melToLMSWithMeasurementError(1,:)', melToLMSWithMeasurementError(2,:)', 'type', 'Spearman');
    
end

plotFig = figure;
h = histogram(rhoWithMeasurementError);
xlabel('Rho With Measurement Error')
ylabel('Frequency')
line([rhoMel rhoMel], [0 max(h.Values)])
mean(rhoWithMeasurementError)
saveas(plotFig, fullfile(outDir, ['perfectTestRetestHistogram.png']), 'png');
close(plotFig);

end % end function


