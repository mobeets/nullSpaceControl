function [ysa, xsa] = cursorProgressAvg(B, grpName, nbins)
    if nargin < 2
        grpName = 'targetAngle';
    end
    if nargin < 3 || isnan(nbins)
        doBin = false;
    elseif ~isnan(nbins)
        doBin = true;
    end
    if isempty(grpName)
        gs = true(size(B.time));
    else
        gs = B.(grpName);
    end
    grps = sort(unique(gs(~isnan(gs))));
    
    xs = B.trial_index;
    ys = B.progress;
    xsa = unique(xs);
    if doBin
        xsa = prctile(xsa, 0:(100/nbins):100)';
    end
    ysa = nan(numel(xsa), numel(grps));

    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        ysc = ys(ix);
        xsc = xs(ix);
        
        for ii = 1:numel(xsa)
            if doBin
                if ii == numel(xsa)
                    continue;
                end
                ix = xsc >= xsa(ii) & xsc <= xsa(ii+1);
                ysa(ii,jj) = nanmean(ysc(ix));
            else
                ysa(ii,jj) = nanmean(ysc(xsc == xsa(ii)));
            end
        end
    end
    if doBin
        xsa = xsa(1:end-1);
        ysa = ysa(1:end-1,:);
    end
end
