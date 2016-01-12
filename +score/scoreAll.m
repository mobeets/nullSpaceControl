function D = scoreAll(D)

    ix = strcmp('observed', {D.hyps.name});
    actual = D.hyps(ix);
    zMu = actual.null.B2.zMu;
    zCov = actual.null.B2.zCov;
    
    for ii = 1:numel(D.hyps)
        if ix(ii)
            D.hyps(ii).errOfMeans = nan;
            D.hyps(ii).covRatio = nan;
        end
        hyp = D.hyps(ii);
        zMu0 = hyp.null.B2.zMu;
        zCov0 = hyp.null.B2.zCov;
        D.hyps(ii).errOfMeans = score.errOfMeans(zMu, zMu0);
        D.hyps(ii).covRatio = score.covRatio(zCov, zCov0);
    end

end
