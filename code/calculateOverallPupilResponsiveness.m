function [ overallPupilResponsiveness ] = calculateOverallPupilResponsiveness(goodSubjects, totalResponseArea, dropboxAnalysisDir)

for session = 1:length(totalResponseArea)
    for ss = 1:length(totalResponseArea{session}.LMS)
        overallPupilResponsiveness{session}(ss) = (totalResponseArea{session}.LMS(ss) + totalResponseArea{session}.Mel(ss) + totalResponseArea{session}.Blue(ss) + totalResponseArea{session}.Red(ss))/4;
    end
end

[ pairedOverallResponsiveness ]  = pairResultAcrossSessions(goodSubjects{1}.ID, goodSubjects{2}.ID, overallPupilResponsiveness{1}, overallPupilResponsiveness{2}, dropboxAnalysisDir, 'xLabel', 'Session 1 Average Responsiveness', 'yLabel', 'Session 2 Average Responsiveness', 'significance', 'rho', 'xLims', [-225 0], 'yLims', [-225 0], 'subdir', 'TPUP', 'saveName', 'overallPupilResponsiveness_1x2')
end % end function