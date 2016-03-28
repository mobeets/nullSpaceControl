function D = scoreAll(D, baseHypNm)
    if nargin < 2
        baseHypNm = 'observed';
    end
    bind = 2; % use 2nd block null map

%     ix = strcmp(baseHypNm, {D.hyps.name});
%     actual = D.hyps(ix).null(bind);
    H = pred.getHyp(D, baseHypNm);
    actual = H.null(bind);
    zNull = actual.zNullBin;
    zMu = actual.zMu;
    zCov = actual.zCov;
    
    for ii = 1:numel(D.hyps)
        if strcmp(D.hyps(ii).name, baseHypNm)
            D.hyps(ii).errOfMeans = nan;
            D.hyps(ii).covRatio = nan;
            D.hyps(ii).covError = nan;
            D.hyps(ii).covErrorOrient = nan;
            D.hyps(ii).covErrorShape = nan;
            continue;
        end
        hyp = D.hyps(ii).null(bind);
        zNull0 = hyp.zNullBin;
        zMu0 = hyp.zMu;
        zCov0 = hyp.zCov;
        if isempty(zMu0)
            continue;
        end
        
        if isequal(size(cell2mat(zNull)), size(cell2mat(zNull0)))
            D.hyps(ii).errOfMeansFull = score.errOfMeans(zNull, zNull0);
        else
            D.hyps(ii).errOfMeansFull = nan;
        end
        [D.hyps(ii).errOfMeans, e2] = score.errOfMeans(zMu, zMu0);
        D.hyps(ii).errOfMeansByKin = e2;
        D.hyps(ii).covRatio = score.covRatio(zCov, zCov0);
        [s,s2,s3] = score.covError(zNull, zNull0);
        D.hyps(ii).covError = s;
        D.hyps(ii).covErrorOrient = s2;
        D.hyps(ii).covErrorShape = s3;
    end

end
