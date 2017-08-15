subjects = {'HERO_HMM', 'HERO_NoFocus', 'HERO_HMM', 'HERO_postMove', 'MELA_0078', 'MELA_0088', 'MELA_0100', 'MELA_0003'};
dates = {'072817', '080217', '080417', '080817', '081017', '081117', '081117', '081517'};
whichValidationList = {'pre', 'pre', 'combined', 'pre','combined', 'combined', 'combined', 'pre'};

for ss = 1:length(subjects)
    [passStatus, validation, backgroundMelLuminance] = analyzeValidation(subjects{ss}, dates{ss}, dropboxAnalysisDir, 'whichValidation', whichValidationList{ss}, 'plot', 'off');
    backgroundMelLuminances(ss) = backgroundMelLuminance;
end

plot(cellfun(@(x) datenum(x, 'mmddyy'), dates), backgroundMelLuminances, 'o')
datetick('x', 'mmddyy')
xlabel('Date of Measurement')
ylabel('Background Luminance for Mel Silent Substitution (cd/m2)')

    