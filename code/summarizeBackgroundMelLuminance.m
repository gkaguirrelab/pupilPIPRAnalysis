function [] = summarizeBackgroundMelLuminance(goodSubjects, dropboxAnalysisDir)

outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/validation');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

pilotSubjects = {'HERO_HMM', 'HERO_NoFocus', 'HERO_HMM', 'HERO_postMove', 'MELA_0003', 'MELA_0038', 'newCodeTest', 'MELA_0084', 'HERO_newCal00_redo', 'HERO_cableTest'};
pilotDates = {'072817', '080217', '080417', '080817', '081517', '081617', '081717', '082117', '082517', '091317'};
pilotWhichValidationList = {'pre', 'pre', 'combined', 'pre', 'pre', 'pre', 'pre','pre', 'pre', 'pre'};

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
set(gcf,'un','n','pos',[.05,.05,.7,.6])
hold on


h1 = plot(cellfun(@(x) datenum(x, 'mmddyy'), combinedDates(1:length(goodSubjects{3}.ID))), backgroundMelLuminances(1:length(goodSubjects{3}.ID)), 'o', 'Color', 'b');
h2 = plot(cellfun(@(x) datenum(x, 'mmddyy'), combinedDates(length(goodSubjects{3}.ID)+1:length(goodSubjects{3}.ID)+length(pilotSubjects))), backgroundMelLuminances(length(goodSubjects{3}.ID)+1:length(goodSubjects{3}.ID)+length(pilotSubjects)), '+', 'Color', 'b');


datetick('x', 'mmddyy')
xlabel('Date of Measurement')
ylabel('Background Luminance for Mel Silent Substitution (cd/m2)')
xlims=get(gca,'xlim');
ylims=get(gca,'ylim');

% add to the plot red dotted line that shows our lower limit of acceptable
% light intensities
h3 = line([xlims(1), xlims(2)], [215, 215], 'Color', 'r', 'LineStyle', '--');


% also want to add to the plot dates in which we've changed the ND filter
% and re-calibrated
datesWhenWeChangedNDFilter = {'081617', '082517'};
% 081617: changed ND filter from 0.2 to 0.1 because light intensity dropped
% below our desired range
% 082517: changed setup, including different bulb (previously the bulb that
% was in box A), eyepiece 1 (switched from eyepiece 2), with 0 ND filter




for date = 1:length(datesWhenWeChangedNDFilter)
    l = line([datenum(datesWhenWeChangedNDFilter{date}, 'mmddyy'), datenum(datesWhenWeChangedNDFilter{date}, 'mmddyy')], [ylims(1), ylims(2)], 'Color', 'k', 'LineStyle', '--');
end

legend([h1 h2], {'Subjects', 'Pilot/Test Data'})


saveas(plotFig, fullfile(outDir, ['backgroundMelLuminance.png']), 'png');
close(plotFig)

splatters = {'SConeContrast', 'LMinusMContrast', 'MelanopsinContrast', 'LMSContrast'};
for splatter = 1:length(splatters)
    for ss = 1:length(goodSubjects{3}.ID)
        [passStatus, validation, backgroundMelLuminance] = analyzeValidation(goodSubjects{3}.ID{ss}, goodSubjects{3}.date{ss}, dropboxAnalysisDir, 'whichValidation', 'combined', 'plot', 'off');
        preSplatterValue.LMS(ss) = median([validation.LMS(1:5).(splatters{splatter})]);
        postSplatterValue.LMS(ss) = median([validation.LMS(6:10).(splatters{splatter})]);
        preSplatterValue.Mel(ss) = median([validation.Melanopsin(1:5).(splatters{splatter})]);
        postSplatterValue.Mel(ss) = median([validation.Melanopsin(6:10).(splatters{splatter})]);
    end
    stimuli = {'Mel', 'LMS'};
    colors = {'c', 'k'};
    for stimulus = 1:2
        if strcmp(stimuli{stimulus}, 'Mel') && strcmp(splatters{splatter}, 'MelanopsinContrast') ||  strcmp(stimuli{stimulus}, 'LMS') && strcmp(splatters{splatter}, 'LMSContrast')
            ylims=[350 450];
        else
            ylims=[-20 20];
        end
        plotFig = figure;
        set(gcf,'un','n','pos',[.05,.05,.7,.6])
        hold on
        [sorted, indices] = sort(goodSubjects{3}.date);
        
        hpre = plot(1:length(preSplatterValue.(stimuli{stimulus})), (preSplatterValue.(stimuli{stimulus})(indices))*100, 'o', 'Color', colors{stimulus});
        hpost = plot(1:length(postSplatterValue.(stimuli{stimulus})), (postSplatterValue.(stimuli{stimulus})(indices))*100, '+', 'Color', colors{stimulus});
        %hpost = plot(cellfun(@(x) datenum(x, 'mmddyy'), goodSubjects{3}.date), postSplatterValue.(stimuli{stimulus})*100, '+', 'Color', colors{stimulus});
  
        title([splatters{splatter}, ' for ', stimuli{stimulus}, ' Directed Modulations'])
        ylabel('Splatter (%)')
        xlabel('Session Date')
        ylim([ylims(1) ylims(2)]); 
        xticks(1:length(preSplatterValue.(stimuli{stimulus})))
        xticklabels(goodSubjects{3}.date(indices))
        %datetick('x', 'mmddyy')
        %xlabel('Date of Measurement')
        
        for date = 1:length(datesWhenWeChangedNDFilter)
            %line([datenum(datesWhenWeChangedNDFilter{date}, 'mmddyy'), datenum(datesWhenWeChangedNDFilter{date}, 'mmddyy')], [ylims(1), ylims(2)], 'Color', 'k', 'LineStyle', '--')
        end
        legend([hpre hpost], {'Pre-Experiment', 'Post-Experiment'})
        saveas(plotFig, fullfile(outDir, [stimuli{stimulus}, 'DirectedModulation_', splatters{splatter}, '.png']), 'png');
        close(plotFig)
        
    end
end






end % end function
