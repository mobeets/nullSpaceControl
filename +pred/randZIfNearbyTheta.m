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
