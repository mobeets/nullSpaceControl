function [ysa, xsa] = cursorProgressAvg(B, grpName)
    if nargin < 2 || isempty(grpName)
        grpName = 'thetaGrps';
    end
    gs = B.(grpName);
    grps = sort(unique(gs(~isnan(gs))));
    
    xs = B.trial_index;
    ys = B.progress;
    xsa = unique(xs);
    ysa = nan(numel(xsa), numel(grps));

    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        ysc = ys(ix);
        xsc = xs(ix);
        for ii = 1:numel(xsa)
            ysa(ii,jj) = nanmean(ysc(xsc == xsa(ii)));
        end
    end

end
