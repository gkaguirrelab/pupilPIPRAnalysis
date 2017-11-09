function [ significance ] = evaluateSignificanceOfMedianDifference(sampleOne, sampleTwo, dropboxAnalysisDir, varargin)

% the variable significance reflects the probability of observing the
% actual median difference or greater, in units of %
%% Parse input
p = inputParser; p.KeepUnmatched = true;
p.addParameter('makePlot',false,@islogical);
p.addParameter('nSimulations',1000000,@isnumeric);
p.addParameter('outDir','permutationTesting',@isnchar);

p.parse(varargin{:});



nSimulations = p.Results.nSimulations;


%% run the permutation testing
result = [];

for nn = 1:nSimulations
    for ss = 1:length(sampleOne)
        shouldWeFlipLabel = round(rand);
        
        if shouldWeFlipLabel == 1 % then flip the label for that subject
            firstGroup(ss) = sampleOne(ss);
            secondGroup(ss) = sampleTwo(ss);
        elseif shouldWeFlipLabel == 0
            secondGroup(ss) = sampleOne(ss);
            firstGroup(ss) = sampleTwo(ss);
        end
    end
    result = [result, median(firstGroup) - median(secondGroup)];
end

observedMedianDifference = median(sampleOne) - median(sampleTwo);
numberOfPermutationsLessThanObserved = result < observedMedianDifference;
significance = 100-(sum(numberOfPermutationsLessThanObserved)/length(result)*100); % in units of %


%% plot the results if specified
if p.Results.makePlot
    
    
    plotFig = figure;
    hold on
    histogram(result);
    ylims=get(gca,'ylim');
    xlims=get(gca,'xlim');
    line([observedMedianDifference, observedMedianDifference], [ylims(1), ylims(2)], 'Color', 'r')
    
    string = (sprintf(['Observed Median Difference = ', num2str(observedMedianDifference), '\n', num2str(sum(numberOfPermutationsLessThanObserved)/length(result)*100), '%% of simulations < Observed Median Difference']));
    
    ypos = 0.9*ylims(2);
    xpos = xlims(1)-0.1*xlims(1);
    text(xpos, ypos, string)

end

end % end function