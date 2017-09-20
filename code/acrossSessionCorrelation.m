function [ rhoMel, melNormedOne, melNormedTwo ] = acrossSessionCorrelation(subjects, amplitudesPerSubject, dropboxAnalysisDir)

% We've shown that a meaningful representation of the pupil response to
% melanopsin stimulation is the amplitude of the pupil constriction to
% melanopsin stimulation normalized by 'pupil responsiveness', for which we
% can use the amplitude of the pupil constriction to LMS stimulation

% This function defines for each subject for each session the melanopsin
% pupil response, and then plots the response from the first session
% against the second session


comparisons = {'MeltoLMS'};

for comparison = 1:length(comparisons)
    [ pairedAmplitudes ] = pairResultAcrossSessions(subjects, amplitudesPerSubject{1}.(comparisons{comparison}), amplitudesPerSubject{2}.(comparisons{comparison}));
    [ pairedAmplitudes_SEM ] = pairResultAcrossSessions(subjects, amplitudesPerSubject{1}.([comparisons{comparison}, '_SEM']), amplitudesPerSubject{2}.([comparisons{comparison}, '_SEM']));

    prettyScatterplots(pairedAmplitudes.sessionOne, pairedAmplitudes.sessionTwo, pairedAmplitudes_SEM.sessionOne, pairedAmplitudes_SEM.sessionTwo, 'stimulation', 'gray', 'grid', 'on', 'axes', 'on', 'xLim', [ -0.2 1.8 ], 'yLim', [ -0.2 1.8 ], 'xLabel', 'Mel/LMS Session 1', 'yLabel', 'Mel/LMS Session 2', 'unity', 'on', 'significance', 'rho', 'plotOption', 'square')

end

% leaving in some old code about some other means of quantifying
% test-retest reliability, including a bland-altman plot
% 
% % compute the test-retest reliability mentioned in the Zhou paper
% for ss = 1:length(melNormedOne)
%     squaredDifference(ss) = (melNormedOne(ss)-melNormedTwo(ss))^2;
%     difference(ss) = melNormedOne(ss)-melNormedTwo(ss);
% end
% 
% % previous method of calculating within subject SD trying to replicate the
% % range dicussed by Zhou
% withinSubjectSD = sqrt(sum(squaredDifference)/(2*length(melNormedOne)));
% testRetestRepeatability = withinSubjectSD*2.77
% 
% % the limits of agreement for a typical bland-altman plot, however, are
% % more simple
% 
% differenceSD = std(difference)
% % the interval in within which we'd expect 95% of the differences between
% % measurements to lie
% plotFig = figure;
% plot((melNormedOne+melNormedTwo)/2, melNormedOne-melNormedTwo, 'o')
% hold on
% line([min((melNormedOne+melNormedTwo)/2) max((melNormedOne+melNormedTwo)/2)], [(mean(melNormedOne-melNormedTwo) + 1.96*differenceSD) (mean(melNormedOne-melNormedTwo) + 1.96*differenceSD)]);
% line([min((melNormedOne+melNormedTwo)/2) max((melNormedOne+melNormedTwo)/2)], [(mean(melNormedOne-melNormedTwo) - 1.96*differenceSD) (mean(melNormedOne-melNormedTwo) - 1.96*differenceSD)]);
% line([min((melNormedOne+melNormedTwo)/2) max((melNormedOne+melNormedTwo)/2)], [(mean(melNormedOne-melNormedTwo)) mean(melNormedOne-melNormedTwo)], 'LineStyle', '--');
% 
% % these lines would be the so-called limits of agreement -- there's a 95%
% % chance the difference between a second measurement and a first measurement 
% % will within this range
% 
% title('Bland-Altman Plot')
% xlabel('Average of the Two Measures')
% ylabel('Difference of the Two Measures')
% saveas(plotFig, fullfile(outDir, ['melNormed_Bland-AltmanPlot.png']), 'png');
% saveas(plotFig, fullfile(outDir, ['melNormed_Bland-AltmanPlot.pdf']), 'pdf');
% 
% close(plotFig);
% 
% 
% 

end % end function