function [zMu, zCov, zByGrp, grps] = avgByThetaGroup(Z, gs)
    
    grps = sort(unique(gs));
    ngrps = numel(grps);
    zMu = cell(ngrps, 1);
    zCov = cell(ngrps, 1);
    zByGrp = cell(ngrps, 1);
    
    noNans = ~any(isnan(Z),2);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs & noNans;
        zCur = Z(ix,:);
        zMu{ii} = mean(zCur)';
        zCov{ii} = cov(zCur);
        zByGrp{ii} = zCur;
    end

end
