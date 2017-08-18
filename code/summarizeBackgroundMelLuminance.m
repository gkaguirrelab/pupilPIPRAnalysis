function [] = summarizeBackgroundMelLuminance(goodSubjects, dropboxAnalysisDir)

pilotSubjects = {'HERO_HMM', 'HERO_NoFocus', 'HERO_HMM', 'HERO_postMove', 'MELA_0003', 'MELA_0038', 'newCodeTest'};
pilotDates = {'072817', '080217', '080417', '080817', '081517', '081617', '081717'};
pilotWhichValidationList = {'pre', 'pre', 'combined', 'pre', 'pre', 'pre', 'pre'};
    
combinedSubjects = horzcat(goodSubjects{3}.ID, pilotSubjects);
combinedDates = horzcat(goodSubjects{3}.date, pilotDates);

for xx = 1:length(goodSubjects{3}.ID)
    goodSubjectsWhichValidation{xx} = 'combined';
end

combinedWhichValidationList = horzcat(goodSubjectsWhichValidation, pilotWhichValidationList);

for ss = 1:length(combinedSubjects)
    [passStatus, validation, backgroundMelLuminance] = analyzeValidation(combinedSubjects{ss}, combinedDates{ss}, dropboxAnalysisDir, 'whichValidation', combinedWhichValidationList{ss}, 'plot', 'off');
    backgroundMelLuminances(ss) = backgroundMelLuminance;
end

plotFig = figure;
hold on


plot(cellfun(@(x) datenum(x, 'mmddyy'), combinedDates(1:length(goodSubjects{3}.ID))), backgroundMelLuminances(1:length(goodSubjects{3}.ID)), 'o', 'Color', 'b')
plot(cellfun(@(x) datenum(x, 'mmddyy'), combinedDates(length(goodSubjects{3}.ID)+1:length(goodSubjects{3}.ID)+length(pilotSubjects))), backgroundMelLuminances(length(goodSubjects{3}.ID)+1:length(goodSubjects{3}.ID)+length(pilotSubjects)), '+', 'Color', 'b')
legend('Subjects', 'Pilot/Test Data')

datetick('x', 'mmddyy')
xlabel('Date of Measurement')
ylabel('Background Luminance for Mel Silent Substitution (cd/m2)')
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');

% add to the plot red dotted line that shows our lower limit of acceptable
% light intensities
line([xlims(1), xlims(2)], [215, 215], 'Color', 'r', 'LineStyle', '--')


% also want to add to the plot dates in which we've changed the ND filter
% and re-calibrated
datesWhenWeChangedNDFilter = {'081617'};
% 081617: changed ND filter from 0.2 to 0.1 because light intensity dropped
% below our desired rang



for date = 1:length(datesWhenWeChangedNDFilter)
    line([datenum(datesWhenWeChangedNDFilter{date}, 'mmddyy'), datenum(datesWhenWeChangedNDFilter{date}, 'mmddyy')], [ylims(1), ylims(2)], 'Color', 'k', 'LineStyle', '--')
end
        


end % end function
