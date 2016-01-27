function grps = thetaGroup(xs, centers)

    bnds = [centers - 22.5 centers + 22.5];
    bnds(bnds < 0) = 360 + bnds(bnds < 0);

    grps = nan(size(bnds,1),1);
    for ii = 1:size(bnds,1)
        grps(tools.isInRange(xs, bnds(ii,:))) = centers(ii);
    end
end
