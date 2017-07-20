function [ responseIntegrationTimes, responseIntegrationTimesSEM ] = analyzeResponseIntegrationTime(goodSubjects, dropboxAnalysisDir)
%% Response integration time is a measure of response duration
% Take from Do 2009: The response integration time (ti), a measure of its
% effective duration and given by ?f(t)dt/fp, where f(t) is the waveform
% and fp is its transient peak amplitude

% This function calculates the response integration time for different
% stimuli. This function further compares the response integration time for
% different stimulations, and also shows the reproducibility of each
% measurement

%% First step: calculate the mean response integration time for each subject,
% for each stimulus, for each session, for each trial

stimulusOrder = {'LMS' 'mel' 'blue' 'red'};

% pre-allocate results variable
for session = 1:2
    for ss = 1:size(goodSubjects{session}{1},1)
        for stimulus = 1:length(stimulusOrder)
            responseIntegrationTimes_byTrial{session}{ss}{stimulus} = [];
        end
    end
end

% create timebase, which is the same for all stimuli
timebase = 0:20:13980;

for session = 1:2;
    for ss = 1:size(goodSubjects{session}{1},1)
        
        subject = goodSubjects{session}{1}(ss,:);
        numberSessions = dir(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject));
        numberSessions =length(numberSessions(~ismember({numberSessions.name},{'.','..', '.DS_Store'})));
        date = goodSubjects{session}{2}(ss,:);
        
        for stimulation = 1:length(stimulusOrder);
            if stimulation == 1; % LMS condition
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseLMS', subject, date, [subject, '_PupilPulseData_MaxLMS_TimeSeries.csv']));
            elseif stimulation == 2; % mel condition
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulseMel', subject, date, [subject, '_PupilPulseData_MaxMel_TimeSeries.csv']));
            elseif stimulation == 3; % blue condition
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRBlue_TimeSeries.csv']));
            elseif stimulation == 4; % red condition
                allTrials = importdata(fullfile(dropboxAnalysisDir, 'PIPRMaxPulse_PulsePIPR', subject, date, [subject, '_PupilPulseData_PIPRRed_TimeSeries.csv']));
            end
            
            numberTrials = size(allTrials,2);
            
            packetCellArray = [];
            for trial = 1:numberTrials
                packetCellArray{trial} = [];
            end
            for trial = 1:numberTrials
                if sum(isnan(allTrials(:,trial))) ~= 700;
                    packetCellArray{trial}.response.values = allTrials(:,trial)';
                else
                    packetCellArray{trial} = [];
                    
                end
            end
            
            packetCellArray = packetCellArray(~cellfun('isempty',packetCellArray));
            
            
            for trial = 1:length(packetCellArray)
                [ responseIntegrationTime ] = calculateResponseIntegrationTime(timebase, packetCellArray{trial}.response.values);
                responseIntegrationTimes_byTrial{session}{ss}{stimulation} = [ responseIntegrationTimes_byTrial{session}{ss}{stimulation}, responseIntegrationTime ];
            end % end loop over trials
        end % end loop over stimuli
    end % end loop over subjects
end % end loop over sessions

%% Bootstrap to determine mean and SEM for each subject for each stimulus for each session
nBootstraps = 10000;
measures = {'lms' 'mel' 'blue' 'red' 'pipr' 'mel/lms' 'blue/red' 'lms+mel' 'blue+red'};


for session = 1:2
    for ss = 1:size(goodSubjects{session}{1},1)
        for mm = 1:length(measures)
            result = [];
            if mm < 5 % for the lms, mel, blue, and red conditions, the bootstrap approach will be the same
                for bb = 1:nBootstraps
                    nTrials = length(responseIntegrationTimes_byTrial{session}{ss}{mm});
                    trialIdx = randsample(1:nTrials, nTrials, true);
                    result = [result, nanmean(responseIntegrationTimes_byTrial{session}{ss}{mm}(trialIdx))];
                end
            elseif mm == 5
                do = 'nothing'; % maybe we'll come back and add a pipr response duration measure
            elseif mm == 6 % mel/lms
                for bb = 1:nBootstraps
                    nMelTrials = length(responseIntegrationTimes_byTrial{session}{ss}{2});
                    nLMSTrials = length(responseIntegrationTimes_byTrial{session}{ss}{1});
                    melTrialIdx = randsample(1:nMelTrials, nMelTrials, true);
                    LMSTrialIdx = randsample(1:nLMSTrials, nLMSTrials, true);
                    result = [result, nanmean(responseIntegrationTimes_byTrial{session}{ss}{2}(melTrialIdx))/nanmean(responseIntegrationTimes_byTrial{session}{ss}{1}(LMSTrialIdx))];
                    
                end
            elseif mm == 7 % blue/red
                
                for bb = 1:nBootstraps
                    nBlueTrials = length(responseIntegrationTimes_byTrial{session}{ss}{3});
                    nRedTrials = length(responseIntegrationTimes_byTrial{session}{ss}{4});
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(responseIntegrationTimes_byTrial{session}{ss}{3}(blueTrialIdx))/nanmean(responseIntegrationTimes_byTrial{session}{ss}{4}(redTrialIdx)))];
                end
                
            elseif mm == 8; % this is the (LMS+mel)/2 condition
                result = [];
                for bb = 1:nBootstraps
                    nMelTrials = length(responseIntegrationTimes_byTrial{session}{ss}{2});
                    nLMSTrials = length(responseIntegrationTimes_byTrial{session}{ss}{1});
                    melTrialIdx = randsample(1:nMelTrials, nMelTrials, true);
                    LMSTrialIdx = randsample(1:nLMSTrials, nLMSTrials, true);
                    result = [result, (nanmean(responseIntegrationTimes_byTrial{session}{ss}{2}(melTrialIdx))+nanmean(responseIntegrationTimes_byTrial{session}{ss}{1}(LMSTrialIdx)))/2];
                end
                
            elseif mm == 9; % this is the (blue+red)/2 condition
                result = [];
                for bb = 1:nBootstraps
                    nBlueTrials = length(responseIntegrationTimes_byTrial{session}{ss}{3});
                    nRedTrials = length(responseIntegrationTimes_byTrial{session}{ss}{4});
                    blueTrialIdx = randsample(1:nBlueTrials, nBlueTrials, true);
                    redTrialIdx = randsample(1:nRedTrials, nRedTrials, true);
                    result = [result, (nanmean(responseIntegrationTimes_byTrial{session}{ss}{3}(blueTrialIdx))+nanmean(responseIntegrationTimes_byTrial{session}{ss}{4}(redTrialIdx)))/2];
                end
            end
            
            responseIntegrationTimes{session}(ss,mm) = nanmean(result);
            responseIntegrationTimesSEM{session}(ss,mm) = nanstd(result);
            
        end
    end
end


%% Make some summary plots to show what the repsonse integration time looks like for each response
%outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/responseIntegrationTime');


for session = 1:2;
    for ss = 1:size(goodSubjects{session}{1},1)
        subject = goodSubjects{session}{1}(ss,:);
        plotFig = figure;
        hold on
        plot(timebase/1000, averageLMSCombined{session}(ss,:), 'Color', 'm')
        plot(timebase/1000, averageMelCombined{session}(ss,:), 'Color', 'c')
        xlims=get(gca,'xlim');
        ylims=get(gca,'ylim');
        xrange = xlims(2)-xlims(1);
        yrange = ylims(2) - ylims(1);
        xpos = xlims(1)+0.60*xrange;
        ypos = ylims(1)+0.20*yrange;
        string = (sprintf(['Mel RIT = ', sprintf('%.2f', responseIntegrationTimes{session}(ss,2)), '\nLMS RIT = ', sprintf('%.2f', responseIntegrationTimes{session}(ss,1))]));
        text(xpos, ypos, string, 'fontsize',12)
        outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/responseIntegrationTime/dataOverview/', num2str(session));

        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        
        saveas(plotFig, fullfile(outDir, [subject, '_SS.pdf']), 'pdf')
        close(plotFig);
        
        subject = goodSubjects{session}{1}(ss,:);
        plotFig = figure;
        hold on
        plot(timebase/1000, averageBlueCombined{session}(ss,:), 'Color', 'b')
        plot(timebase/1000, averageRedCombined{session}(ss,:), 'Color', 'r')
        xlims=get(gca,'xlim');
        ylims=get(gca,'ylim');
        xrange = xlims(2)-xlims(1);
        yrange = ylims(2) - ylims(1);
        xpos = xlims(1)+0.60*xrange;
        ypos = ylims(1)+0.20*yrange;
        string = (sprintf(['Blue RIT = ', sprintf('%.2f', responseIntegrationTimes{session}(ss,3)), '\nRed RIT = ', sprintf('%.2f', responseIntegrationTimes{session}(ss,4))]));
        text(xpos, ypos, string, 'fontsize',12)
        outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/responseIntegrationTime/dataOverview/', num2str(session));
        if ~exist(outDir, 'dir')
            mkdir(outDir);
        end
        
        saveas(plotFig, fullfile(outDir, [subject, '_PIPR.pdf']), 'pdf')
        close(plotFig);
    end
end


%% Summarize how temporal integration varies as a function of stimulus
        outDir = fullfile(dropboxAnalysisDir,'pupilPIPRAnalysis/responseIntegrationTime/');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

for session = 1:2
    for stimulation = 1:length(stimulusOrder)
        meanResponseIntegrationTimes(stimulation) = nanmean(responseIntegrationTimes{session}(:,stimulation));
        SEMResponseIntegrationTimes(stimulation) = nanstd(responseIntegrationTimes{session}(:,stimulation))/sqrt(length(responseIntegrationTimes{session}(:,stimulation)));
    end
    
    plotFig = figure;
    b = barwitherr(SEMResponseIntegrationTimes, meanResponseIntegrationTimes);
    set(gca,'XTickLabel',stimulusOrder)
    title('Mean Response Integration Time')
    saveas(plotFig, fullfile(outDir, ['meanResponseIntegrationTime_byStimulus_session', num2str(session), '.pdf']), 'pdf');
    close(plotFig)
    
end % end loop over sessions

% including look for a correlation between response integration times for
% different stimulations
for session = 1:2
    plotFig = figure;
    prettyScatterplots(responseIntegrationTimes{session}(:,1), responseIntegrationTimes{session}(:,2), responseIntegrationTimesSEM{session}(:,1), responseIntegrationTimesSEM{session}(:,2), 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'xLabel', 'LMS', 'yLabel', 'Mel', 'significance', 'rho')
    saveas(plotFig, fullfile(outDir, ['lmsXmel_session', num2str(session),  '.pdf']), 'pdf');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(responseIntegrationTimes{session}(:,3), responseIntegrationTimes{session}(:,4), responseIntegrationTimesSEM{session}(:,3), responseIntegrationTimesSEM{session}(:,4), 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'xLabel', 'Blue', 'yLabel', 'Red', 'significance', 'rho')
    saveas(plotFig, fullfile(outDir, ['blueXred_session', num2str(session),  '.pdf']), 'pdf');
    close(plotFig)
    
    plotFig = figure;
    prettyScatterplots(responseIntegrationTimes{session}(:,8), responseIntegrationTimes{session}(:,9), responseIntegrationTimesSEM{session}(:,8), responseIntegrationTimesSEM{session}(:,9), 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'xLabel', 'Mel+LMS', 'yLabel', 'Blue+Red', 'significance', 'rho')
    saveas(plotFig, fullfile(outDir, ['lms+melXblue+red_session', num2str(session),  '.pdf']), 'pdf');
    close(plotFig)
    
end
%% Look at test-retest reliability of the melanopsin measure of response integration time

[melResponseIntegrationTimeCombined] = pairResultAcrossSessions(goodSubjects, responseIntegrationTimes{1}(:,2), responseIntegrationTimes{2}(:,2));
[melResponseIntegrationTimeSEMCombined] = pairResultAcrossSessions(goodSubjects, responseIntegrationTimesSEM{1}(:,2), responseIntegrationTimesSEM{2}(:,2));

plotFig = figure;
prettyScatterplots(melResponseIntegrationTimeCombined{1}, melResponseIntegrationTimeCombined{2}, melResponseIntegrationTimeSEMCombined{1}, melResponseIntegrationTimeSEMCombined{2}, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'xLim', [ 2e+03 6e+03 ], 'yLim', [ 2e+03 6e+03 ], 'xLabel', 'Mel Session 1', 'yLabel', 'Mel Session 2', 'unity', 'on', 'significance', 'rho', 'plotOption', 'square')
saveas(plotFig, fullfile(outDir, ['testRetest_mel.pdf']), 'pdf');
close(plotFig)

[melNormedResponseIntegrationTimeCombined] = pairResultAcrossSessions(goodSubjects, responseIntegrationTimes{1}(:,6), responseIntegrationTimes{2}(:,6));
[melNormedResponseIntegrationTimeSEMCombined] = pairResultAcrossSessions(goodSubjects, responseIntegrationTimesSEM{1}(:,6), responseIntegrationTimesSEM{2}(:,6));

plotFig = figure;
prettyScatterplots(melNormedResponseIntegrationTimeCombined{1}, melNormedResponseIntegrationTimeCombined{2}, melNormedResponseIntegrationTimeSEMCombined{1}, melNormedResponseIntegrationTimeSEMCombined{2}, 'stimulation', 'gray', 'grid', 'on', 'axes', 'off', 'xLim', [0 2.5], 'yLim', [0, 2.5], 'xLabel', 'Mel Normed Session 1', 'yLabel', 'Mel Normed Session 2', 'unity', 'on', 'significance', 'rho', 'plotOption', 'square')
saveas(plotFig, fullfile(outDir, ['testRetest_melNormed.pdf']), 'pdf');
close(plotFig)

end % end function



function [ responseIntegrationTime ] = calculateResponseIntegrationTime(timebase, response)

responseIntegrationTime = abs(trapz(timebase, response))/max(abs(response));

end % end function