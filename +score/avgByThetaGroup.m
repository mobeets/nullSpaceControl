function [ms, ses, grp, grps] = avgByThetaGroup(xs, ys, centers)

    grps = score.thetaGroup(xs, centers);
    [ms, ses, grp] = score.calcGroupMeanAndSE(grps, ys);

end
