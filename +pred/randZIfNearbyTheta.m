function Zsamp = randZIfNearbyTheta(theta, B, theta_tol)
    if nargin < 3
        theta_tol = 15;
    end

    bnds = [theta - theta_tol; theta + theta_tol];
    nearbyIdxs = tools.targsInRange(B.thetas + 180, bnds);
    ix = randi(numel(nearbyIdxs));
    Zsamp = B.latents(ix,:);

end
