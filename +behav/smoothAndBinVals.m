function [xsb, ysb, nsb, Ysc] = smoothAndBinVals(xsc, ysc, opts)
    if nargin < 3
        opts = struct();
    end
    defopts = struct('binSz', 100, 'minPtsPerBin', 10, ...
        'doMeanPerTrial', true, 'doSlidingBins', true, ...
        'useVarAsReduce', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if opts.useVarAsReduce
        reduceFcn = @(y) nanvar(y);
    else
        reduceFcn = @(y) nanmean(y);
    end
    
    % define trial bins
    xsa = sort(unique(xsc));
    if opts.doSlidingBins
        xsb = xsa(xsa < max(xsa)-opts.binSz);
    else
        xsb = min(xsa) + (0:opts.binSz:range(xsa));
        if max(xsa) ~= max(xsb)
            xsb = [xsb max(xsb)];
        end
        xsb = xsb';
    end

    % take mean of each value per trial
    if opts.doMeanPerTrial
        ysc = grpstats(ysc, xsc, @nanmean);
        xsc = xsa;
    end

    % fcn of current Y per bin
    ysb = nan(numel(xsb), 1);
    nsb = nan(numel(xsb), 1);
    Ysc = cell(numel(xsb), 1);
    for jj = 1:numel(xsb)-1
        if opts.doSlidingBins
            it = xsc >= xsb(jj) & xsc <= xsb(jj)+opts.binSz;
        else
            it = xsc >= xsb(jj) & xsc <= xsb(jj+1);
        end
        if sum(it) < opts.minPtsPerBin
            continue;
        end
        nNonNan = sum(~any(isnan(ysc(it,:)),2));
        if nNonNan < opts.minPtsPerBin
            continue;
        end
        ysb(jj) = reduceFcn(ysc(it,:));
        nsb(jj) = nNonNan;
        Ysc{jj} = ysc(it,:);
    end
end
