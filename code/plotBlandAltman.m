function plotBlandAltman(goodSubjects, firstSessionResult, secondSessionResult, dropboxAnalysisDir)

[ melNormed ] = pairResultAcrossSessions(goodSubjects, firstSessionResult, secondSessionResult);


for ss = 1:length(melNormed.sessionOne)
    difference(ss) = melNormed.sessionOne(ss)-melNormed.sessionTwo(ss);
end


% the limits of agreement for a typical bland-altman plot, however, are
% more simple

differenceSD = std(difference);
% the interval in within which we'd expect 95% of the differences between
% measurements to lie
plotFig = figure;
hold on

prettyScatterplots((melNormed.sessionOne+melNormed.sessionTwo)/2, melNormed.sessionOne-melNormed.sessionTwo, (melNormed.sessionOne-melNormed.sessionTwo)*0, (melNormed.sessionOne-melNormed.sessionTwo)*0, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'dotSize', 7, 'xLim', [-0.2 1.4], 'yLim', [-1 1], 'unity', 'off', 'plotOption', 'square')
line([min((melNormed.sessionOne+melNormed.sessionTwo)/2) max((melNormed.sessionOne+melNormed.sessionTwo)/2)], [(mean(melNormed.sessionOne-melNormed.sessionTwo) + 1.96*differenceSD) (mean(melNormed.sessionOne-melNormed.sessionTwo) + 1.96*differenceSD)], 'Color', 'k');
line([min((melNormed.sessionOne+melNormed.sessionTwo)/2) max((melNormed.sessionOne+melNormed.sessionTwo)/2)], [(mean(melNormed.sessionOne-melNormed.sessionTwo) - 1.96*differenceSD) (mean(melNormed.sessionOne-melNormed.sessionTwo) - 1.96*differenceSD)], 'Color', 'k');
line([min((melNormed.sessionOne+melNormed.sessionTwo)/2) max((melNormed.sessionOne+melNormed.sessionTwo)/2)], [(mean(melNormed.sessionOne-melNormed.sessionTwo)) mean(melNormed.sessionOne-melNormed.sessionTwo)], 'LineStyle', '--', 'Color', 'k');

% these lines would be the so-called limits of agreement -- there's a 95%
% chance the difference between a second measurement and a first measurement
% will within this range

title('Bland-Altman Plot')
xlabel('Average of the Two Measures')
ylabel('Difference of the Two Measures')



outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

set(gcf,'Renderer','painters')
saveas(plotFig, fullfile(outDir, ['4b.pdf']), 'pdf');

close(plotFig);

end % end function