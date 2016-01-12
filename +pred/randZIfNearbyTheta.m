function Zsamp = randZIfNearbyTheta(theta, B, theta_tol)
    if nargin < 3
        theta_tol = 15;
    end

    nearbyIdxs = getNearbyThetaIdxs(theta, B.theta, theta_tol);
    ix = randi(numel(nearbyIdxs));
    Zsamp = B.latents(:,ix);

end

function ixs = getNearbyThetaIdxs(theta, thetas, tol)
    ixs = [];
end
