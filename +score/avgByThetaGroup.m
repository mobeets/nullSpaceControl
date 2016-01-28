function [ms, ses, grp, grps] = avgByThetaGroup(xs, ys, centers, theta_tol)
    if nargin < 4
        theta_tol = nan;
    end

    grps = score.thetaGroup(xs, centers, theta_tol);
    [ms, ses, grp] = score.calcGroupMeanAndSE(grps, ys, centers);

end
