function Zsamp = randZIfNearbyTheta(theta, B, theta_tol, takeTheMean)
    if nargin < 3 || isnan(theta_tol)
        theta_tol = 15;
    end
    if nargin < 4
        takeTheMean = false;
    end

    bnds = mod([theta - theta_tol theta + theta_tol], 360);    
    nearbyIdxs = tools.isInRange(B.thetas + 180, bnds);
    if takeTheMean
        Zsamp = mean(B.latents(nearbyIdxs,:));
        return;
    end
    inds = 1:numel(nearbyIdxs);
    inds = inds(nearbyIdxs);
    ix = randi(numel(inds));
    Zsamp = B.latents(inds(ix),:);    

end
