function grps = thetaGroup(xs, centers, theta_tol)
    if nargin < 3 || isnan(theta_tol)
        theta_tol = 22.5;
    end

    bnds = mod([centers - theta_tol centers + theta_tol], 360);

    grps = nan(size(xs,1),1);
    for ii = 1:size(bnds,1)
        grps(tools.isInRange(xs, bnds(ii,:))) = centers(ii);
    end

end
