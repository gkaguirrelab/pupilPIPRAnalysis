function [ percentPersistentPerSubject ] = calculatePercentPersistent(goodSubjects, TPUPParameters)

stimuli = {'LMS', 'Mel', 'Blue', 'Red'};

for session = 1:length(TPUPParameters)
    for stimulus = 1:length(stimuli)
        for ss = 1:length(TPUPParameters{session}.(stimuli{stimulus}).delay)
            percentPersistent = TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss)/(TPUPParameters{session}.(stimuli{stimulus}).transientAmplitude(ss) + TPUPParameters{session}.(stimuli{stimulus}).sustainedAmplitude(ss) + TPUPParameters{session}.(stimuli{stimulus}).persistentAmplitude(ss));
            percentPersistentPerSubject{session}.(stimuli{stimulus})(ss) = percentPersistent;
        end
    end
end

%% Look for relationships between percent persistent across stimuli
for session = 1:length(TPUPParameters)
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Blue, percentPersistentPerSubject{session}.Red, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Blue')
    ylabel('Red')
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.LMS, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Mel')
    ylabel('LMS')
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Mel')
    ylabel('Blue')
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.Mel, percentPersistentPerSubject{session}.Red, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('Mel')
    ylabel('Red')
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.LMS, percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('LMS')
    ylabel('Blue')
    
    plotFig = figure;
    prettyScatterplots(percentPersistentPerSubject{session}.LMS, percentPersistentPerSubject{session}.Red, 0*percentPersistentPerSubject{session}.Blue, 0*percentPersistentPerSubject{session}.Red, 'significance', 'rho')
    xlabel('LMS')
    ylabel('Red')
end

%% Look for test re-test reliability of the measures
for stimulus = 1:length(stimuli)
    plotFig = figure;
    [percentPersistentPaired] = pairResultAcrossSessions(goodSubjects, percentPersistentPerSubject{1}.(stimuli{stimulus}), percentPersistentPerSubject{2}.(stimuli{stimulus}))
    prettyScatterplots(percentPersistentPaired.sessionOne, percentPersistentPaired.sessionTwo, 0*percentPersistentPaired.sessionOne, 0*percentPersistentPaired.sessionOne, 'significance', 'rho')
    title(stimuli{stimulus})
end

