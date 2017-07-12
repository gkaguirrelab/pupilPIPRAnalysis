function plotBlandAltman(goodSubjects, firstSessionResult, secondSessionResult, dropboxAnalysisDir)

[ melNormed ] = pairResultAcrossSessions(goodSubjects, firstSessionResult, secondSessionResult);


for ss = 1:length(melNormed{1})
    difference(ss) = melNormed{1}(ss)-melNormed{2}(ss);
end


% the limits of agreement for a typical bland-altman plot, however, are
% more simple

differenceSD = std(difference);
% the interval in within which we'd expect 95% of the differences between
% measurements to lie
plotFig = figure;
hold on

prettyScatterplots((melNormed{1}+melNormed{2})/2, melNormed{1}-melNormed{2}, (melNormed{1}-melNormed{2})*0, (melNormed{1}-melNormed{2})*0, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'dotSize', 7, 'xLim', [-0.2 1.4], 'yLim', [-1 1], 'unity', 'off', 'plotOption', 'square')
line([min((melNormed{1}+melNormed{2})/2) max((melNormed{1}+melNormed{2})/2)], [(mean(melNormed{1}-melNormed{2}) + 1.96*differenceSD) (mean(melNormed{1}-melNormed{2}) + 1.96*differenceSD)], 'Color', 'k');
line([min((melNormed{1}+melNormed{2})/2) max((melNormed{1}+melNormed{2})/2)], [(mean(melNormed{1}-melNormed{2}) - 1.96*differenceSD) (mean(melNormed{1}-melNormed{2}) - 1.96*differenceSD)], 'Color', 'k');
line([min((melNormed{1}+melNormed{2})/2) max((melNormed{1}+melNormed{2})/2)], [(mean(melNormed{1}-melNormed{2})) mean(melNormed{1}-melNormed{2})], 'LineStyle', '--', 'Color', 'k');

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