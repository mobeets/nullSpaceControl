function D = scoreAll(D)

    bind = 2; % use 2nd block
    
    ix = strcmp('observed', {D.hyps.name});
    actual = D.hyps(ix).null(bind);
    zNull = actual.zNullBin;
    zMu = actual.zMu;
    zCov = actual.zCov;
    
    for ii = 1:numel(D.hyps)
        if ix(ii)
            D.hyps(ii).errOfMeans = nan;
            D.hyps(ii).covRatio = nan;
        end
        hyp = D.hyps(ii).null(bind);
        zNull0 = hyp.zNullBin;
        zMu0 = hyp.zMu;
        zCov0 = hyp.zCov;
        if isempty(zMu0)
            continue;
        end
        
        D.hyps(ii).errOfMeansFull = score.errOfMeans(zNull, zNull0);
        D.hyps(ii).errOfMeans = score.errOfMeans(zMu, zMu0);
        D.hyps(ii).covRatio = score.covRatio(zCov, zCov0);
    end

end
