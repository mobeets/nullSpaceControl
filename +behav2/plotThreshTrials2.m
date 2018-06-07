function obj = plotThreshTrials2(xs, ys, opts)
    defopts = struct('muThresh', 0.5, 'varThresh', 0.5, ...
        'meanBinSz', 100, 'varBinSz', 100, 'maxTrialSkip', 10, ...
        'minGroupSize', 100, 'lastBaselineTrial', 50);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % get mean value per trial
    xsb = unique(xs);
    ysb = grpstats(ys, xs);
    if numel(ysb) < opts.meanBinSz
        obj = struct('isGood', false); return;
    end
    ysSmoothMean = smooth(xsb, ysb, opts.meanBinSz);
    
    % find running mean, and normalize
    yMean_min = nanmin(ysSmoothMean((opts.lastBaselineTrial+1):end-10));
    yMean_max = max(ysSmoothMean(1:opts.lastBaselineTrial));
    ysSmoothMeanNorm = normToZeroOne(ysSmoothMean, yMean_min, yMean_max);
    ixMean = ysSmoothMeanNorm <= opts.muThresh;
    
    % find running var, and normalize
    ysSmoothVar = runningVar(ysSmoothMean, opts.varBinSz);
    yVar_min = nanmin(ysSmoothVar);
    vVar_max = nanmax(ysSmoothVar(1:ceil(numel(ysSmoothVar)/2)));
    ysSmoothVarNorm = normToZeroOne(ysSmoothVar, yVar_min, vVar_max);
    ixVar = ysSmoothVarNorm <= opts.varThresh;
    
    % combine and find run
    ixBoth = ixMean & ixVar;
    ix = findBestRun(xsb, ysSmoothMeanNorm, ixBoth, opts.minGroupSize, ...
        opts.maxTrialSkip);
    if sum(ix) < opts.minGroupSize
        isGood = false;
    else
        isGood = sum(~isnan(ysSmoothMeanNorm)) > 0 & ...
            max(xsb(ix))-min(xsb(ix)) >= opts.minGroupSize;
    end
    
    clear obj;
    obj.ix = ix;
    obj.isGood = isGood;
    obj.ixMean = ixMean;
    obj.ixVar = ixVar;    
    obj.xsb = xsb;
    obj.ysb = ysb;
    obj.ysSmoothMean = ysSmoothMean;
    obj.ysSmoothMeanNorm = ysSmoothMeanNorm;
    obj.ysSmoothVar = ysSmoothVar;
    obj.ysSmoothVarNorm = ysSmoothVarNorm;
end

function vs = normToZeroOne(vs, mn, mx)
    vs = (vs - mn)./(mx - mn);
end

function v = runningVar(x, m)
    n = size(x,1);
    f = zeros(m,1) + 1/m;
    v = filter2(f, x.^2, 'valid') - filter2(f, x, 'valid').^2;
    m2 = floor(m/2);
    n2 = ceil(m/2) - 1;
    v = v([zeros(1,m2)+m2+1,(m2+1):(n-n2), zeros(1,n2)+(n-n2)]-m2,:);
    assert(isequal(numel(v), numel(x)));
end

function ixBest = findBestRun(xs, ys, ix, minGroupSize, maxTrialSkip)
    % for groups of consecutive xs, find best set of corresponding ys
    % where groups must have at least minGroupSize elements
    xsc = xs(ix);
    ysc = ys(ix);
    
    % need at least minGroupSize trials to count
    if numel(ysc) < minGroupSize
        ixBest = false(size(ix));
        return;
    end
    
    ymx = -inf;
    % find indices where trials change by more than trialsInARow
    % (i.e., if trialsInARow=2, [1 3 5] would be counted as one group)
    groupChangeInds = [0 find(diff(xsc) >= maxTrialSkip)' numel(xsc)];
    for kk = 2:numel(groupChangeInds)
        cinds = (groupChangeInds(kk-1)+1):groupChangeInds(kk);
        if numel(cinds) < minGroupSize
            continue;
        end
        ycur = numel(ysc(cinds));
        if ycur > ymx
           ymx = ycur;
           bestInds = cinds;
       end
    end
    
    % no adjacent indices with at least minGroupSize elements
    if isempty(bestInds)
        ixBest = false(size(ix));
        return;
    end
    
    % make mask same size as ix, but with bestInds marked
    yx = double(ix);
    yx(ix>0) = 1:sum(ix>0);
    ixBest = ismember(yx, bestInds);
end
