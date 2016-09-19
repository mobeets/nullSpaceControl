function nullActivityPerBasisColumn(xs, ys, zs, doScatter, doMean, clr)
% xs [nt x 1] - cursor angle from target
% ys [nt x nn] - activity for each column/neuron
% zs [nt x 1] - target location
% 
% one panel per column of ys
% one color per unique value of zs
% averages are calculated for all ys where xs is within range of 
%   one of the unique values in zs
% 
   
    if nargin < 4
        doScatter = true;
    end
    if nargin < 5
        doMean = true;
    end
    if nargin < 6
        clr = nan;
    end
    npanels = size(ys,2);
    nrows = ceil(sqrt(npanels));
    ncols = round(npanels/nrows);
    
    nrows = 1;
    ncols = npanels;
    
    grps = sort(unique(zs));
    [Gms, Gstds, Gses, ~, Gs] = score.avgByThetaGroup(xs, ys, grps);
        
    if doScatter
        ymx = ceil(max(abs(ys(:))));        
    else
        ymx = ceil(max(abs(Gms(:))));
    end
%     ymn = -2;
    ymx = max(ymx, 2);
    ymx = 3;
    for jj = 1:npanels
        subplot(nrows, ncols, jj);
        set(gca, 'FontSize', 14);
        
%         polarPlotMean(Gs, Gms(:,jj), ymn);
%         hold on;
%         continue;

        hold on;
        if doScatter
            scatterByColorGroup(xs, ys(:,jj), zs, false);
        end
        if doMean
%             plotGroupMeanAndSE(Gs, Gms(:,jj), 2*Gses(:,jj), clr);
            plotGroupMeanAndSE(Gs, Gms(:,jj), Gstds(:,jj), clr);
        end
        
        xlim([-50 370]);        
%         ylim([-ymx ymx]);
        plot(xlim, [0 0], '--', 'Color', [0.5 0.5 0.5]);
        set(gca, 'XTick', grps(1:4:end));
        set(gca, 'XTickLabel', grps(1:4:end));
        set(gca, 'XTickLabelRotation', 45);
        
        if jj == 1
            xlabel('\theta');
            ylabel('activity in column');
            set(gcf, 'color', 'w');
        end
    end        
end

function polarPlotMean(xs, ys, ymn)
    lw = 2;
    xvals = [deg2rad(xs); deg2rad(xs(1))];
    yvals = [ys - ymn; ys(1) - ymn];
    h = polar(xvals, max(yvals, 0));
    set(h, 'LineWidth', lw);
end

function scatterByColorGroup(xs, ys, grps, doWrap)
    if nargin < 4
        doWrap = false;
    end
    sz = 10;
    allgrps = sort(unique(grps));
    cmap = cbrewer('div', 'RdYlGn', numel(allgrps));
%     cmap = circshift(cmap, floor(numel(allgrps)/2));
    
    % plot scatter of each point
    for ii = 1:numel(allgrps)
        ix = (grps == allgrps(ii));
        xsc = xs(ix);
        if doWrap
            xsc = wrapLargeDegrees(xsc);
        end        
        scatter(xsc, ys(ix), sz, cmap(ii,:));
    end
end

function xs = wrapLargeDegrees(xs)    
    if mean(xs < 20) > 0.2 && mean(xs > 300) > 0.2
        xs(xs > 300) = xs(xs > 300) - 360;
    end
end

function plotGroupMeanAndSE(xs, ms, ses, clr, clrE)
    if nargin < 5 || all(isnan(clrE))
        clrE = 0.8*ones(3,1);
    end
    if nargin < 4 || all(isnan(clr))
        clr = 0.8*ones(3,1);
    end
    sz = 20;
    lw = 3;

%     plot(xs, ms - ses, 'Color', clrE);
%     plot(xs, ms + ses, 'Color', clrE);
    X = [xs', fliplr(xs')];
    Y = [(ms - ses)', fliplr((ms + ses)')];
    f = fill(X, Y, clr);
    set(f, 'EdgeColor', 'none');
    alpha(f, 0.2);
    plot(xs, ms, '-', 'Color', clr, 'LineWidth', lw);
    scatter(xs, ms, sz, clr, 'MarkerFaceColor', clr);
end
