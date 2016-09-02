function [ms, stds, ses, covs, grp, grps] = avgByThetaGroup(xs, ys, centers)

    grps = score.thetaGroup(xs, centers);
    [ms, stds, ses, covs, grp] = score.calcGroupMeanAndSE(grps, ys, centers);

end
