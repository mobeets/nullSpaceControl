function [zMu, zCov, zStd, zNullBin] = avgByThetaGroup(B, zNull)

    xs = B.thetas;
    centers = score.thetaCenters(8);
    ntargs = numel(centers);
    
    theta_tol = 22.5;
    bnds = mod([centers - theta_tol centers + theta_tol], 360);
    
    zMu = cell(ntargs,1);
    zStd = cell(ntargs,1);
    zCov = cell(ntargs,1);
    zNullBin = cell(ntargs,1);

    % if some predictions are nan, only score on non-nans
    ix0 = ~isnan(sum(zNull,2));
    for ii = 1:numel(centers)
        % for each trial in ix, keep times where DecTrg is in Akc
%         ix = targs == alltargs(ii);
        ix = tools.isInRange(xs, bnds(ii,:)) & ix0;
        zNullCur = zNull(ix,:);
        zNullBin{ii} = zNullCur;
        zMu{ii} = mean(zNullCur)';
        zStd{ii} = (std(zNullCur)/sqrt(numel(zNullCur)))';
        zCov{ii} = (cov(zNullCur));
    end

end
