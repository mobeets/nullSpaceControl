function Zsamp = randZIfNearbyMinTheta(theta, B, theta_tol, nthresh)
% starts with low theta_tol and increases if it can't find any in that
% range
    if nargin < 3
        theta_tol = 2;
    end
    if nargin < 4
        nthresh = nan;
    end

    bnds = [theta - theta_tol; theta + theta_tol];
    nearbyIdxs = tools.isInRange(B.thetas + 180, bnds);
    inds = 1:numel(nearbyIdxs);
    inds = inds(nearbyIdxs);
    if numel(inds) == 0 || (~isnan(nthresh) && numel(inds) > nthresh)
        Zsamp = pred.randZIfNearbyMinTheta(theta, B, 1.2*theta_tol);
        return;
    end
    ix = randi(numel(inds));
    Zsamp = B.latents(inds(ix),:);

end
