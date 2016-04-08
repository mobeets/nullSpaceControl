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
        D.hyps(ii).errOfMeansByKinByCol = (cell2mat(zMu') - cell2mat(zMu0')).^2';
        [D.hyps(ii).errOfMeans, e2] = score.errOfMeans(zMu, zMu0);
        D.hyps(ii).errOfMeansByKin = e2;
        D.hyps(ii).covRatio = score.covRatio(zCov, zCov0);
        [s, s2, s3, S,S2,S3] = score.covError(zNull, zNull0);
        D.hyps(ii).covError = s;
        D.hyps(ii).covErrorOrient = s2;
        D.hyps(ii).covErrorShape = s3;
        D.hyps(ii).covErrorByKin = S;
        D.hyps(ii).covErrorOrientByKin = S2;
        D.hyps(ii).covErrorShapeByKin = S3;
        [isUndr, isOver, isEither] = checkBounds(D.hyps(ii).latents, H.latents);
        if isEither > 0
            disp([D.hyps(ii).name ' hypothesis has ' num2str(isEither) ...
                ' points out of bounds (' num2str(isUndr) ' under, ' ...
                num2str(isOver) ' over).']);
        end
    end
end

function [isUndr, isOver, isEither] = checkBounds(Zh, Z)
    mns = min(Z);
    mxs = max(Z);
    mnsc = repmat(mns, size(Z,1), 1);
    mxsc = repmat(mxs, size(Z,1), 1);
    isUndr = sum(Zh < mnsc,2);
    isOver = sum(Zh > mxsc,2);
    isEither = isOver + isUndr > 0;
    
    isUndr = sum(isUndr);
    isOver = sum(isOver);
    isEither = sum(isEither);
end
