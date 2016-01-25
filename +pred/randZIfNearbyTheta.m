function Zsamp = randZIfNearbyTheta(theta, B, theta_tol)
    if nargin < 3
        theta_tol = 15;
    end

    bnds = [theta - theta_tol; theta + theta_tol];
    nearbyIdxs = tools.isInRange(B.thetas + 180, bnds);
    inds = 1:numel(nearbyIdxs);
    inds = inds(nearbyIdxs);
    ix = randi(numel(inds));
    Zsamp = B.latents(inds(ix),:);
%     Zsamp = mean(B.latents(nearbyIdxs,:));

end

function Zsamp = randZIfNearbyMinTheta(theta, B, theta_tol)
% starts with low theta_tol and increases if it can't find any in that
% range
    if nargin < 3
        theta_tol = 2;
    end

    bnds = [theta - theta_tol; theta + theta_tol];
    nearbyIdxs = tools.isInRange(B.thetas + 180, bnds);
    inds = 1:numel(nearbyIdxs);
    inds = inds(nearbyIdxs);
    if numel(inds) == 0
        Zsamp = pred.randZIfNearbyTheta(theta, B, 1.2*theta_tol);
        return;
    end
    ix = randi(numel(inds));
    Zsamp = B.latents(inds(ix),:);

end
