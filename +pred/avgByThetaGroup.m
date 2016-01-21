function [zMu, zCov, zStd] = avgByThetaGroup(B, zNull)

    decTargs = B.thetas + 180;

    targs = B.targetAngle;
    alltargs = unique(targs)'; % rad2deg((0:7).*(pi/4));
    ntargs = numel(alltargs);
    Ak = [alltargs - 22.5; alltargs + 22.5]';
    Ak(Ak < 0) = 360 + Ak(Ak < 0);
    
    zMu = cell(ntargs,1);
    zStd = cell(ntargs,1);
    zCov = cell(ntargs,1);

    for ii = 1:numel(alltargs)
        % for each trial in ix, keep times where DecTrg is in Akc
%         ix = targs == alltargs(ii);
        ix = tools.isInRange(decTargs, Ak(ii,:));

        zNullCur = zNull(ix,:);
        zMu{ii} = mean(zNullCur)';
        zStd{ii} = (std(zNullCur)/sqrt(numel(zNullCur)))';
        zCov{ii} = (cov(zNullCur))';
    end

end
