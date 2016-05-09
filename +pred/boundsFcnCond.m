function isOutOfBoundsFcn = boundsFcnCond(yr, YR, YN, opts)
    if ~isfield(opts, 'boundsThresh') || ...
            isinf(opts.boundsThresh) || isnan(opts.boundsThresh)
        isOutOfBoundsFcn = @(z) false;
        return;
    end
    % find distances of YR from yr; keep those within some distance thresh
    ds = sqrt(sum(bsxfun(@minus, YR, yr).^2,2));
%     nearbyIdxs = ds <= prctile(ds, opts.localThresh);
    nearbyIdxs = ds <= opts.boundsThresh;    
    if sum(nearbyIdxs) == 0
        isOutOfBoundsFcn = @(z) false;
    else
        isOutOfBoundsFcn = pred.boundsFcn(YN(nearbyIdxs,:), opts.boundsType);
    end
end
