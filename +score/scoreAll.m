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
            D.hyps(ii).covError = nan;
            D.hyps(ii).covErrorOrient = nan;
            D.hyps(ii).covErrorShape = nan;
        end
        hyp = D.hyps(ii).null(bind);
        zNull0 = hyp.zNullBin;
        zMu0 = hyp.zMu;
        zCov0 = hyp.zCov;
        if isempty(zMu0)
            continue;
        end
        
        if isequal(size(zNull{1}), size(zNull0{1}))
            D.hyps(ii).errOfMeansFull = score.errOfMeans(zNull, zNull0);
        else
            D.hyps(ii).errOfMeansFull = nan;
        end
        D.hyps(ii).errOfMeans = score.errOfMeans(zMu, zMu0);
        D.hyps(ii).covRatio = score.covRatio(zCov, zCov0);
        [s,s2,s3] = score.covError(zNull, zNull0);
        D.hyps(ii).covError = s;
        D.hyps(ii).covErrorOrient = s2;
        D.hyps(ii).covErrorShape = s3;
    end

end
