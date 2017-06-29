function [ averageResult ] = averageResultAcrossSubjects(result)

%% function to create average result across subjects
% flexibly takes in result variable, provides average result across
% subjects
% main use case: generating average timeseries data

% note: differnt rows are assumed to be different subjects, what we're
% averaging across


for xx = 1:size(result,2) % looping over timepoints to be averaged over
    averageResult(1,xx) = nanmean(result(:,xx));
end

end
