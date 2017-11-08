function [ ] = prettyScatterPlots(x, y, varargin)

%close all

p = inputParser; p.KeepUnmatched = true;


p.addParameter('stimulation','greyScale',@ischar);
p.addParameter('save','none',@ischar);
p.addParameter('saveType','none',@ischar);
p.addParameter('plotOption','none',@ischar);
p.addParameter('lineOfBestFit','none',@ischar);
p.addParameter('xLabel','none',@ischar);
p.addParameter('unity','none',@ischar);
p.addParameter('grid','none',@ischar);
p.addParameter('axes','none',@ischar);
p.addParameter('yLabel','none',@ischar);
p.addParameter('xLim','none',@isnumeric);
p.addParameter('yLim','none',@isnumeric);
p.addParameter('dotSize',8,@isnumeric);
p.addParameter('significance','none',@ischar);
p.addParameter('close','none',@ischar);
p.addParameter('subplot','none',@isvector);
p.addParameter('title','',@ischar);
p.addParameter('xError',[],@ismatrix);
p.addParameter('yError',[],@ismatrix);







% fmake sure the data vectors are oriented the correct way. this is to
% correct there error where i would be transposing individual arrays to get the correlations to run right
if size(x,1) == 1
    x = x';
end
if size(y,1) == 1
    y = y';
end

p.parse(varargin{:});

if strcmp(p.Results.subplot, 'none')
else
    subplot(p.Results.subplot(1), p.Results.subplot(2), p.Results.subplot(3))
end

if strcmp(p.Results.title, '')
else
    title(p.Results.title)
end

if strcmp(p.Results.stimulation, 'greyScale')
    
    colors = colormap('bone');
    errorBarColor = colors(20,:);
    markerEdgeColor = colors(8,:);
    markerFaceColor = colors(58,:);
end
if strcmp(p.Results.stimulation, 'gray')
    errorBarColor = [0.59, 0.59, 0.59];
    markerEdgeColor = [0.4, 0.4, 0.4];
    markerFaceColor = [0.9, 0.9, 0.9];
end
if strcmp(p.Results.stimulation, 'blue')
    errorBarColor = [ 0.1, 0.1, 1];
    markerEdgeColor = [ 0, 0, 1];
    markerFaceColor = [ 0.8, 0.8, 1];
end
if strcmp(p.Results.stimulation, 'red')
    errorBarColor = [ 1, 0.1, 0.1];
    markerEdgeColor = [ 1, 0, 0];
    markerFaceColor = [ 1, 0.8, 0.8];
end


hold on



% figure out how to deal with error bars
if isempty(p.Results.xError)
    xError = zeros(1,length(x));
    errbar(x, y, xError, 'horiz', 'Color', errorBarColor)
end
if isempty(p.Results.yError)
    yError = zeros(1,length(y));
    errbar(x, y, yError, 'Color', errorBarColor)
end

if size(p.Results.xError, 1) == 1
    errbar(x, y, p.Results.xError, 'horiz', 'Color', errorBarColor)
end

if size(p.Results.yError, 1) == 1
    errbar(x, y, p.Results.yError, 'Color', errorBarColor)
end


% note that with asymmetric error bars, the value refers to how far from
% the point to place the boundary (value - errorValue), rather than just
% explicitly defining that boundary (errorValue)
if size(p.Results.xError, 1) == 2
    xErrorLowerBounds = p.Results.xError(1,:);
    xErrorUpperBounds = p.Results.xError(2,:);
    errbar(x, y, xErrorLowerBounds, xErrorUpperBounds, 'horiz', 'Color', errorBarColor)
end

if size(p.Results.yError, 1) == 2
    yErrorLowerBounds = p.Results.yError(1,:);
    yErrorUpperBounds = p.Results.yError(2,:);
    errbar(x, y, yErrorLowerBounds, yErrorUpperBounds, 'Color', errorBarColor)
end
    
    

scatterPlot = plot(x,y, 'o');

set(scatterPlot                            , ...
    'LineWidth'       , 0.0000001           , ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , p.Results.dotSize           , ...
    'MarkerEdgeColor' , markerEdgeColor  , ...
    'MarkerFaceColor' , [1, 1, 1]  );

scatterPlot = plot(x,y, 'o');

set(scatterPlot                            , ...
    'LineWidth'       , 0.0000001           , ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , p.Results.dotSize           , ...
    'MarkerEdgeColor' , markerEdgeColor  , ...
    'MarkerFaceColor' , markerFaceColor  );

scatterPlot = plot(x,y, 'o');

set(scatterPlot                            , ...
    'LineWidth'       , 0.000001           , ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , p.Results.dotSize           , ...
    'MarkerEdgeColor' , markerEdgeColor  );



if strcmp(p.Results.unity, 'on')
    plot(-1000:1000, -1000:1000, '-.', 'Color', errorBarColor)
end

if strcmp(p.Results.xLim, 'none')
else
    xlim([p.Results.xLim(1) p.Results.xLim(2)])
end

if strcmp(p.Results.yLim, 'none')
else
    ylim([p.Results.yLim(1), p.Results.yLim(2)])
end



if strcmp(p.Results.xLabel, 'none') && strcmp(p.Results.yLabel, 'none')
else
    xlabel(p.Results.xLabel)
    ylabel(p.Results.yLabel)
end

if strcmp(p.Results.plotOption, 'none')
elseif strcmp(p.Results.plotOption, 'squareFromZero')
    
    maxValue = max(max(x,y));
    xlim([ 0 maxValue ]);
    ylim([ 0 maxValue ]);
    pbaspect([1 1 1])
elseif strcmp(p.Results.plotOption, 'square')
    pbaspect([1 1 1])
end

if strcmp(p.Results.lineOfBestFit, 'none')
elseif strcmp(p.Results.lineOfBestFit, 'on')
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x);
        if xnan(xx) == 1;
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 1)
end

if strcmp(p.Results.significance, 'r')
    r = corr2(x, y);
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    string = (sprintf(['r = ', num2str(r)]));
    text(xpos, ypos, string, 'fontsize',12)
elseif strcmp(p.Results.significance, 'pearson')
    r = corr2(x, y);
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    string = (sprintf(['r = ', num2str(r)]));
    text(xpos, ypos, string, 'fontsize',12)
elseif strcmp(p.Results.significance, 'rho')
    rho = corr(x, y, 'type', 'Spearman');
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    string = (sprintf(['rho = ', sprintf('%.2f', rho)]));
    text(xpos, ypos, string, 'fontsize',12)
elseif strcmp(p.Results.significance, 'spearman')
    rho = corr(x, y, 'type', 'Spearman');
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    string = (sprintf(['rho = ', sprintf('%.2f', rho)]));
    text(xpos, ypos, string, 'fontsize',12)
end



if strcmp(p.Results.axes, 'off')
  
    ax1 = gca;
    %yruler = ax1.YRuler;
    %yruler.Axle.Visible = 'off';
    %xruler = ax1.XRuler;
    %xruler.Axle.Visible = 'off';
    ax1.YGrid = 'off';
    ax1.XGrid = 'off';
    %set(gca, 'xtick', []);
    %set(gca, 'ytick', []);
    set(gca, 'Ticklength', [0 0])
    
end



if strcmp(p.Results.grid, 'on')
    grid on
end

%'lineOfBestFit', square, statistic, squareFromZero




if strcmp(p.Results.save, 'none');
else
    if strcmp(p.Results.saveType, 'png')
        
        
        saveas(scatterPlot, fullfile(p.Results.save), 'png');
    elseif strcmp(p.Results.saveType, 'pdf')
        saveas(scatterPlot, fullfile(p.Results.save), 'pdf');
    end
    
    
end

if strcmp(p.Results.close, 'on')
    close
end


