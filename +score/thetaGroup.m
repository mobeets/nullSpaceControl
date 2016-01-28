function grps = thetaGroup(xs, centers, theta_tol)
    if nargin < 3 || isnan(theta_tol)
        theta_tol = 22.5;
    end

    bnds = [centers - theta_tol centers + theta_tol];
    bnds(bnds < 0) = 360 + bnds(bnds < 0);

    grps = nan(size(bnds,1),1);
    for ii = 1:size(bnds,1)
        grps(tools.isInRange(xs, bnds(ii,:))) = centers(ii);
    end
end
