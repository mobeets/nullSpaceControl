function Zsamp = randZIfNearbyTheta(theta, B, theta_tol, takeTheMean, ...
    useActuals, offset)
    if nargin < 3
        theta_tol = nan;
    end
    if nargin < 4
        takeTheMean = false;
    end
    if nargin < 5
        useActuals = false;
    end
    if nargin < 6
        offset = 0;
    end
    if useActuals
        thNm = 'thetaActuals';
    else
        thNm = 'thetas';
    end

    if isnan(theta_tol)
        bnds = [0 360];
    else
        bnds = mod([theta - theta_tol theta + theta_tol], 360);
    end
    ths = mod(B.(thNm) + offset, 360);
    nearbyIdxs = tools.isInRange(ths, bnds);
    if takeTheMean
        Zsamp = nanmean(B.latents(nearbyIdxs,:));
        return;
    end
    inds = 1:numel(nearbyIdxs);
    inds = inds(nearbyIdxs);
    ix = randi(numel(inds));
    Zsamp = B.latents(inds(ix),:);    

end
