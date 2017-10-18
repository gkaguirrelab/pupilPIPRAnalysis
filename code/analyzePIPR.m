function analyzePIPR(goodSubjects, amplitudesPerSubject, dropboxAnalysisDir)

% Although actually computing the PIPR is trivial, making sense of the
% result is challenging. This function creates various plots to attempt to
% understand different aspects of the PIPR: how different measures of the
% PIPR relate to each other, how varying light intensity affects the PIPR,
% and how PIPR relates to our other measures of the melanopsin response.


%% there are different methods by which we can compute the PIPR response: how do they relate to each other?
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/PIPR', 'comparePIPRs');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% compute the PIPR by the window approach. Specifically, designate the
% entire period following light-off as the sustained window, and calculate
% the PIPR based on the average amplitude of sustained constriction during
% this sustained window. Note of course that there are lots of ways we
% could determine this window
[piprWindow, netPIPRWindow] = calculatePIPR(goodSubjects, amplitudesPerSubject, dropboxAnalysisDir, 'computeMethod', 'window', 'timeOn', 4, 'timeOff', 14);

% We also proposed to calculate the PIPR on the basis of our amplitude of
% pupil constriction to blue and red stimuli obtained via IAMP modeling.
% Specifically the PIPR then is the amplitude of constriction in response
% to blue stimulation minus the amplitude of constriction in response to
% red stimulation
[piprTotalAmplitude, netPIPRTotalAmplitude] = calculatePIPR(goodSubjects, amplitudesPerSubject, dropboxAnalysisDir, 'computeMethod', 'totalAmplitude');

% In our pre-registration for the third session, we specifically said we
% would normalize this measure of the PIPR for overall pupil response
% amplitude (here the sum of amplitude of constriction to blue and red
% stimulus) So the netPIPRTotalAmplitudeNormed is (Blue-Red)/(Blue+Red)
[piprTotalAmplitudeNormed, netPIPRTotalAmplitudeNormed] = calculatePIPR(goodSubjects, amplitudesPerSubject, dropboxAnalysisDir, 'computeMethod', 'totalAmplitudeNormed');

% now look at some plots to look at the relationships of these different
% measures. All of these comparisons are going to be exlusively with the
% net PIPR (ie blue - red) because we believe we need to red response to
% assess any residual cone contribution
for session = 1:3
    
    % window vs. total amplitude
    plotFig = figure;
    prettyScatterplots(netPIPRWindow{session}, netPIPRTotalAmplitude{session}*100, netPIPRWindow{session}*0, netPIPRWindow{session}*0, 'xLim', [-7 12], 'yLim', [-5 25], 'significance', 'rho')
    xlabel('Net PIPR from Window Method (% Change)')
    ylabel('Net PIPR from Total Amplitude Method (% Change)')
    saveas(plotFig, fullfile(outDir, 'windowXTotalAmplitude.png'), 'png')
    
    % window vs. total amplitude normed
    plotFig = figure;
    prettyScatterplots(netPIPRWindow{session}, netPIPRTotalAmplitudeNormed{session}*100, netPIPRWindow{session}*0, netPIPRWindow{session}*0, 'xLim', [-7 12], 'yLim', [-5 27], 'significance', 'rho')
    xlabel('Net PIPR from Window Method (% Change)')
    ylabel('Net PIPR from Total Amplitude Method Normed (%)')
    saveas(plotFig, fullfile(outDir, 'windowXTotalAmplitudeNormed.png'), 'png')
    
    % total amplitude vs. total amplitude normed
    plotFig = figure;
    prettyScatterplots(netPIPRTotalAmplitude{session}*100, netPIPRTotalAmplitudeNormed{session}*100, netPIPRWindow{session}*0, netPIPRWindow{session}*0, 'xLim', [-7 12], 'yLim', [-10 25], 'significance', 'rho')
    xlabel('Net PIPR from TotalAmplitude (% Change)')
    ylabel('Net PIPR from Total Amplitude Method Normed (%)')
    saveas(plotFig, fullfile(outDir, 'totalAmplitudeXTotalAmplitudeNormed.png'), 'png')
    
end

close all

%% How Session 3 relates to session 1/2
outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/PIPR', 'compareSessions');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end


PIPRs = {'netPIPRWindow', 'netPIPRTotalAmplitude', 'netPIPRTotalAmplitudeNormed'};
for pp = 1:length(PIPRs)
    plotFig = figure;
    hold on
    result = eval(PIPRs{pp});
    bplot(result{1}, 1, 'color', 'k');
    bplot(result{2}, 2, 'color', 'k');
    bplot(result{3}, 3, 'color', 'k');
    xlabel('Session')
    ylabel(PIPRs{pp})
    saveas(plotFig, fullfile(outDir, [PIPRs{pp}, '_boxPlot.png']), 'png')
    
    plotFig = figure;
    data = horzcat({result{1}', result{2}', result{3}'});
    plotSpread(data, 'distributionMarkers', 'o', 'xNames', {'Session 1', 'Session 2', 'Session 3'})
    ylabel(PIPRs{pp})
    saveas(plotFig, fullfile(outDir, [PIPRs{pp}, '_spread.png']), 'png')
end

close all

%% How do different measurs of the PIPR relate to measures of the melanopsin response elicited through silent substitution?


SSMethods = {'Mel', 'MeltoLMS'};
PIPRs = {'netPIPRWindow', 'netPIPRTotalAmplitude', 'netPIPRTotalAmplitudeNormed'};
for session = 1:3
    outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/PIPR', 'compareStimulationMethod', num2str(session));
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    for xx = 1:length(PIPRs)
        for yy = 1:length(SSMethods)
            PIPRResult = eval(PIPRs{xx});
            
            plotFig = figure;
            prettyScatterplots(PIPRResult{session}, amplitudesPerSubject{session}.(SSMethods{yy}), 0*PIPRResult{session}, PIPRResult{session}*0, 'xLabel', PIPRs{xx}, 'yLabel', SSMethods{yy}, 'significance', 'rho')
            saveas(plotFig, fullfile(outDir, [PIPRs{xx}, 'x', SSMethods{yy}, '.png']), 'png')
        end
    end
end
close all

end % end function

