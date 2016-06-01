function h = optimalBinCount(Y, gs, doPlot)
% for each group, for each column, calculate LOO c-v score for histogram
%   for a range of bin counts
% now, take the mean of the z-scores of these scores across columns
%   and then take the mean of these resulting scores across groups
% returns the bin count minimizing the above score
%
% c-v score sources:
%  * http://toyoizumilab.brain.riken.jp/hideaki/res/histogram.html
%  * http://www.utdallas.edu/epps/statbook/apps/histogram.php
%
    if nargin < 3
        doPlot = false;
    end

%     Y = D.hyps(1).nullActivity.zNull;
%     gs = D.blocks(2).thetaActualGrps;
%     gs = ones(size(Y,1),1);

    crit = @(cs,h,n) 2./((n-1).*h) - sum(cs.^2)*(n+1)./((n-1)*n^2.*h);
%     crit = @(cs,h,n) (2*mean(cs) - var(cs, 1))/h^2;
    xs = 10:200;
    
    grps = sort(unique(gs));
    yc = cell(numel(grps),1);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        Yc = Y(ix,:);
        n = size(Yc,1);
        rng = max(max(Yc)) - min(min(Yc)); % range of histogram

        cfcn = @(h) tools.marginalDist(Yc, ones(n,1), struct('nbins', h, ...
            'getCounts', true));
        getcellind = @(fcn, ind) fcn{ind};
        obj = @(h) crit(getcellind(cfcn(h), 1), rng/h, n); % rng/h == binsz
        
        ys = cell2mat(arrayfun(obj, xs, 'uni', 0)');
        yc{ii} = mean(zscore(ys), 2);        
    end
    
    ya = mean(cell2mat(yc'),2);
    [~,ix] = min(ya);
    h = xs(ix);
    if doPlot
        plot.init;
        for jj = 1:numel(yc)
            plot(xs, yc{jj}, '-');
        end
        plot(xs, ya, 'k-', 'LineWidth', 3);
        plot([h h], ylim, 'k--');
        xlabel('# bins');
        ylabel('c-v score');
    end    

end
