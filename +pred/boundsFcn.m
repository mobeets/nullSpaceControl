function isOutOfBoundsFcn = boundsFcn(Y)
    mns = min(Y);
    mxs = max(Y);
    isOutOfBoundsFcn = @(z) all(isnan(z)) || ...
        (sum(z < mns) > 0 || sum(z > mxs) > 0);
end
