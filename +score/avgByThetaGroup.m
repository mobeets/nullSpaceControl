function [ms, ses, covs, grp, grps] = avgByThetaGroup(xs, ys, centers)

    grps = score.thetaGroup(xs, centers);
    [ms, ses, covs, grp] = score.calcGroupMeanAndSE(grps, ys, centers);

end
