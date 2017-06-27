function acrossStimulusCorrelations(amplitudes, amplitudesSEM, dropboxAnalysisDir)

% set up where to save our plots
subDir = 'pupilPIPRAnalysis/IAMP/acrossStimulusCorrelations';

for session = 1:2
    
    %plot correlation of LMS and Mel
    plotFig = figure;
    hold on
    x = amplitudes{session}(:,1)*100;
    y = amplitudes{session}(:,2)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    errorbar(amplitudes{session}(:,1)*100, amplitudes{session}(:,2)*100, 100*amplitudesSEM{session}(:,2), 'bo')    
    herrorbar(amplitudes{session}(:,1)*100, amplitudes{session}(:,2)*100, 100*amplitudesSEM{session}(:,1), 'bo')    
    plot(-100:100,-100:100,'-')

    xlabel('LMS Amplitude (%)')
    ylabel('Mel Amplitude (%)')
    r = corr2(amplitudes{session}(:,1), amplitudes{session}(:,2));
    legend(['r = ', num2str(r)])
    hold on
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
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateLMSxMel.png']), 'png');
    close(plotFig);
    
    prettyScatterplots(amplitudes{session}(:,1)*100, amplitudes{session}(:,2)*100, 100*amplitudesSEM{session}(:,1), 100*amplitudesSEM{session}(:,2), 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'LMS Amplitude (%)', 'yLabel', 'Melanopsin Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'spearman', 'save', fullfile(outDir, ['correlateLMSxMel_pretty.png']), 'saveType', 'png')
    
    
    % plot correlation of Mel and PIPR
    plotFig = figure;
    hold on
    x = amplitudes{session}(:,5)*100;
    y = amplitudes{session}(:,2)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    errorbar(amplitudes{session}(:,5)*100, amplitudes{session}(:,2)*100, amplitudesSEM{session}(:,2)*100, 'bo')    
    herrorbar(amplitudes{session}(:,5)*100, amplitudes{session}(:,2)*100, amplitudesSEM{session}(:,5)*100, 'bo')    
    plot(-100:100,-100:100,'-')

    xlabel('PIPR Amplitude (%)')
    ylabel('Mel Amplitude (%)')
    r = corr2(amplitudes{session}(:,5), amplitudes{session}(:,2));
    legend(['r = ', num2str(r)])
    hold on
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
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir, subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateMelxPIPR.png']), 'png');
    close(plotFig);
    
    % plot correlation of PIPR and LMS
    plotFig = figure;
    hold on
    y = amplitudes{session}(:,1)*100;
    x = amplitudes{session}(:,5)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    errorbar(amplitudes{session}(:,5)*100, amplitudes{session}(:,1)*100, amplitudesSEM{session}(:,1)*100, 'bo')
    herrorbar(amplitudes{session}(:,5)*100, amplitudes{session}(:,1)*100, amplitudesSEM{session}(:,5)*100, 'bo')
    plot(-100:100,-100:100,'-')

    ylabel('LMS Amplitude (%)')
    xlabel('PIPR Amplitude (%)')
    r = corr2(amplitudes{session}(:,5)*100, amplitudes{session}(:,1));
    legend(['r = ', num2str(r)])
    hold on
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
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateLMSxPIPR.png']), 'png');
    close(plotFig);
    
    % plot correlation of blue and red
    plotFig = figure;
    hold on
    x = amplitudes{session}(:,3)*100;
    y = amplitudes{session}(:,4)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    errorbar(amplitudes{session}(:,3)*100,amplitudes{session}(:,4)*100, amplitudesSEM{session}(:,4)*100, 'bo')
    herrorbar(amplitudes{session}(:,3)*100,amplitudes{session}(:,4)*100, amplitudesSEM{session}(:,3)*100, 'bo')
    plot(-100:100,-100:100,'-')

    xlabel('Blue Amplitude (%)')
    ylabel('Red Amplitude (%)')
    r = corr2(amplitudes{session}(:,3), amplitudes{session}(:,4));
    legend(['r = ', num2str(r)])
    hold on
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
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    axis square
    outDir = fullfile(dropboxAnalysisDir,subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateBluexRed.png']), 'png');
    close(plotFig);
    
    prettyScatterplots(amplitudes{session}(:,3)*100, amplitudes{session}(:,4)*100, 100*amplitudesSEM{session}(:,3), 100*amplitudesSEM{session}(:,4), 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', 'Blue Amplitude (%)', 'yLabel', 'Red Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, ['correlateBluexRed_pretty.png']), 'saveType', 'png')

    
    % plot correlation of [blue + red]/2 and [LMS + mel]/2
    plotFig = figure;
    hold on
    x = amplitudes{session}(:,9)*100;
    y = amplitudes{session}(:,8)*100;
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    errorbar(amplitudes{session}(:,9)*100,amplitudes{session}(:,8)*100, amplitudesSEM{session}(:,8)*100, 'bo')
    herrorbar(amplitudes{session}(:,9)*100, amplitudes{session}(:,8)*100, amplitudesSEM{session}(:,9)*100, 'bo')
    plot(-100:100,-100:100,'-')

    xlabel('(Blue+Red)/2 Amplitude (%)')
    ylabel('(LMS+Mel)/2 Amplitude (%)')
    r = corr2(amplitudes{session}(:,9)*100,amplitudes{session}(:,8)*100);
    legend(['r = ', num2str(r)])
    hold on
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
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    xlim([0 60]);
    ylim([0 60]);
    
    axis square
    outDir = fullfile(dropboxAnalysisDir,subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateBlueRedxMelLMS.png']), 'png');
    close(plotFig);
    
        prettyScatterplots(amplitudes{session}(:,9)*100, amplitudes{session}(:,8)*100, 100*amplitudesSEM{session}(:,9), 100*amplitudesSEM{session}(:,8), 'xLim', [0 60], 'yLim', [0 60], 'unity', 'on', 'plotOption', 'square', 'xLabel', '(Blue+Red)/2 Amplitude (%)', 'yLabel', '(Mel+LMS)/2 Amplitude (%)', 'lineOfBestFit', 'on', 'significance', 'r', 'save', fullfile(outDir, ['correlateBlueRedxMelLMS_pretty.png']), 'saveType', 'png')

    % plot correlation of [blue/red] and [mel/lms]
    x=[];
    y=[];
    plotFig = figure;
    hold on
    %for tt = 1:length(amplitudes{session}(:,4))
     %   x(tt) = amplitudes{session}(tt,3)/amplitudes{session}(tt,4);
     %   y(tt) = (amplitudes{session}(tt,2)/amplitudes{session}(tt,1));
    %end
    x = amplitudes{session}(:,7);
    y = amplitudes{session}(:,6);
    combined = [x; y];
    maxValue = max(combined);
    minValue = min(combined);
    %covarianceMelLMS = cov(amplitudes{session}(:,1), amplitudes{session}(:,2));
    %covarianceMelLMS = covarianceMelLMS(1,2);
    %semMelOverLMS = sqrt(1./((amplitudes{session}(:,1).^2)).*(amplitudesSTD{session}(:,2).^2)+(amplitudes{session}(:,2).^2)./(amplitudes{session}(:,1).^4).*(amplitudesSTD{session}(:,1).^2)-2*amplitudes{session}(:,2)./(amplitudes{session}(:,1).^3)*covarianceMelLMS)./sqrt((numberOfTrials{session}(:,1)+numberOfTrials{session}(:,2))/2);
    %covarianceBlueRed = cov(amplitudes{session}(:,3), amplitudes{session}(:,4));
    %covarianceBlueRed = covarianceBlueRed(1,2);
    %semBlueOverRed = sqrt(1./((amplitudes{session}(:,4).^2)).*(amplitudesSTD{session}(:,3).^2)+(amplitudes{session}(:,3).^2)./(amplitudes{session}(:,4).^4).*(amplitudesSTD{session}(:,4).^2)-2*amplitudes{session}(:,3)./(amplitudes{session}(:,4).^3)*covarianceBlueRed)./sqrt((numberOfTrials{session}(:,3)+numberOfTrials{session}(:,4))/2);
    %covarianceBlueRed = cov(amplitudes{session}(:,3), amplitudes{session}(:,4));
    errorbar(amplitudes{session}(:,7), amplitudes{session}(:,6), amplitudesSEM{session}(:,6), 'bo')
    herrorbar(amplitudes{session}(:,7), amplitudes{session}(:,6), amplitudesSEM{session}(:,7), 'bo')
    plot(-100:100,-100:100,'-')
    xlim([minValue maxValue])
    ylim([minValue maxValue])

    xlabel('Blue/Red Amplitude')
    ylabel('Mel/LMS Amplitude')
    r = corr2(x, y);
    legend(['r = ', num2str(r)])
    hold on
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
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 3)
    
    outDir = fullfile(dropboxAnalysisDir,subDir, num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    saveas(plotFig, fullfile(outDir, ['correlateBlueToRedxMelToLMS.png']), 'png');
    close(plotFig);
    
end % end loop over sessions

close all

end % end function