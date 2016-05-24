function isOutOfBoundsFcn = boundsFcnCond(yr, YR, YN, boundsThresh, boundsType)
    if nargin < 5
        boundsType = 'marginal';
    end
    if isinf(boundsThresh) || isnan(boundsThresh)
        isOutOfBoundsFcn = @(z) false;
        return;
    end
    % find distances of YR from yr; keep those within some distance thresh
    ds = sqrt(sum(bsxfun(@minus, YR, yr).^2,2));
%     nearbyIdxs = ds <= prctile(ds, opts.localThresh);
    nearbyIdxs = ds <= boundsThresh;    
    if sum(nearbyIdxs) == 0
        isOutOfBoundsFcn = @(z) false;
    else
        isOutOfBoundsFcn = pred.boundsFcn(YN(nearbyIdxs,:), ...
            boundsType);
    end
end
