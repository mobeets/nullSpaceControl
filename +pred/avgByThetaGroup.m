function [zMu, zCov, zStd, zNullBin] = avgByThetaGroup(B, zNull)

    decTargs = B.thetas + 180;

    targs = B.targetAngle;
    alltargs = unique(targs)'; % rad2deg((0:7).*(pi/4));
    ntargs = numel(alltargs);
    Ak = [alltargs - 22.5; alltargs + 22.5]';
    Ak(Ak < 0) = 360 + Ak(Ak < 0);
    
    zMu = cell(ntargs,1);
    zStd = cell(ntargs,1);
    zCov = cell(ntargs,1);
    zNullBin = cell(ntargs,1);

    % if some predictions are nan, only score on non-nans
    ix0 = ~isnan(sum(zNull,2));
%     ix0 = B.idxTest || ~any(isnan(sum(zNull,2)));
    for ii = 1:numel(alltargs)
        % for each trial in ix, keep times where DecTrg is in Akc
%         ix = targs == alltargs(ii);
        ix = tools.isInRange(decTargs, Ak(ii,:)) & ix0;

        zNullCur = zNull(ix,:);
        zNullBin{ii} = zNullCur;
        zMu{ii} = mean(zNullCur)';
        zStd{ii} = (std(zNullCur)/sqrt(numel(zNullCur)))';
        zCov{ii} = (cov(zNullCur))';
    end

end
