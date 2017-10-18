function [ totalResponseArea ] = calculateTotalResponseArea(TPUPParameters, dropboxAnalysisDir)

stimuli = {'LMS', 'Mel', 'Blue', 'Red'};

for session = 1:length(TPUPParameters)
    for stimulus = 1:length(stimuli)
        for ss = 1:length(TPUPParameters{session}.(stimuli{stimulus}).delay)
            totalResponseArea{session}.(stimuli{stimulus})(ss) = ...
                TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude(ss) ...
                + TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude(ss) ...
                + TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss);
        end % end loop over subjects
    end % end loop over stimuli
end % end loop over sessions

end % end function

