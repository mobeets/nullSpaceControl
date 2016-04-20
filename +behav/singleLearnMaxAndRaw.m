function [L_best, L_max, L_raw, ls] = singleLearnMaxAndRaw(xs, bs, flipSign, binSz)
    if nargin < 3 || isnan(flipSign)
        flipSign = false;
    end
    if nargin < 4
        binSz = 50;
    end
    if ~isnan(binSz)
        [vs, vsbs] = behav.binValues(xs, bs, binSz);
    else
        vs = xs;
        vsbs = bs;
    end
    if flipSign
        vs = -vs;
    end

    vsz = zscore(vs);

    % learning metrics
    P_B = nanmean(vsz(vsbs == 1)); % avg in intuitive block
    P_P = vsz(vsbs == 2); % values in perturbation block
    L_max = P_B - P_P(1); % learning hit
    L_raw = P_P - P_P(1); % change in learning
    L_best = max(L_raw);
    
    % other calculated values
    ls.P_B = P_B;
    ls.P_P = P_P;
    ls.vals = vs;
    ls.vals_nrm = vsz;
    ls.blkind = vsbs;
    ls.vals_ts = xs;
    ls.vals_blkind = bs;

end
