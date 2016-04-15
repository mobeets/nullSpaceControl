function [L_best, L_max, L_raw, ls] = singleLearnMaxAndRaw(xs, bs, binSz)
    if nargin < 3
        binSz = 50;
    end    

    % mean per bin, zscore
    lbs = 1:binSz:numel(xs);
    vs = nan(size(lbs));
    vsbs = nan(size(lbs));
    for ii = 1:numel(lbs)
        lb = lbs(ii);
        ub = lb + binSz - 1;
        if ub > numel(xs)
            continue;
        end
        if ii < numel(lbs)
            assert(ub == lbs(ii+1)-1);
        end
        vs(ii) = mean(xs(lb:ub));
        vsbs(ii) = mean(bs(lb:ub));
    end

    % remove last if nan (due to incomplete bin)
    if isnan(vs(end))
        vsbs = vsbs(1:end-1);
        vs = vs(1:end-1);
    end

    vsz = zscore(vs);

    % learning metrics
    P_B = mean(vsz(vsbs == 1)); % avg in intuitive block
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
