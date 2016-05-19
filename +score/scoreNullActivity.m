function D = scoreNullActivity(D, opts)
    defopts = struct('doBoots', true, 'baseHypNm', 'observed', ...
        'scoreBlkInd', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

%     ix = strcmp(baseHypNm, {D.hyps.name});
%     actual = D.hyps(ix).null(bind);
    H = pred.getHyp(D, opts.baseHypNm);
    actual = H.null(opts.scoreBlkInd);
    zNull = actual.zNullBin;
    zMu = actual.zMu;
    zCov = actual.zCov;
    
    for ii = 1:numel(D.hyps)        
        if strcmp(D.hyps(ii).name, opts.baseHypNm)
            D.hyps(ii).errOfMeans = nan;
            D.hyps(ii).covRatio = nan;
            D.hyps(ii).covError = nan;
            D.hyps(ii).covErrorOrient = nan;
            D.hyps(ii).covErrorShape = nan;
            D.hyps(ii).errOfMeansByKin = nan;
            D.hyps(ii).grps = D.hyps(ii).null(opts.scoreBlkInd).grps;
            continue;
        end
        hyp = D.hyps(ii).null(opts.scoreBlkInd);
        zNull0 = hyp.zNullBin;
        zMu0 = hyp.zMu;
        zCov0 = hyp.zCov;
        grps = hyp.grps;
        if isempty(zMu0)
            continue;
        end
        
        if isequal(size(cell2mat(zNull)), size(cell2mat(zNull0)))
            D.hyps(ii).errOfMeansFull = score.errOfMeans(zNull, zNull0);
        else
            D.hyps(ii).errOfMeansFull = nan;
        end
        D.hyps(ii).grps = grps;
        D.hyps(ii).errOfMeansByKinByCol = abs(cell2mat(zMu') - cell2mat(zMu0'))';
        [D.hyps(ii).errOfMeans, e2, e3] = score.errOfMeans(zMu, zMu0);
        D.hyps(ii).pctErrOfMeansByKin = e3; % pct of norm captured
        D.hyps(ii).errOfMeansByKin = e2; % errs by mean
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
        if opts.doBoots
            D = handleBootstrapScores(D, ii);
        end        
    end    
end

function D = handleBootstrapScores(D, ii)
% n.b. can't pass D.hyps(ii) because we have to 
%   modify it within scope of the full hyps struct
%
    if ~isfield(D.hyps(ii), 'errOfMeans_boots')
        assert(~isfield(D.hyps(ii), 'errOfMeansByKin_boots'));
        D.hyps(ii).errOfMeans_boots = [];
        D.hyps(ii).covError_boots = [];
        D.hyps(ii).covErrorShape_boots = [];
        D.hyps(ii).covErrorOrient_boots = [];
        
        D.hyps(ii).errOfMeansByKin_boots = [];
        D.hyps(ii).covErrorByKin_boots = [];
        D.hyps(ii).covErrorShapeByKin_boots = [];
        D.hyps(ii).covErrorOrientByKin_boots = [];
    end
    D.hyps(ii).errOfMeans_boots = [D.hyps(ii).errOfMeans_boots; ...
        D.hyps(ii).errOfMeans];
    D.hyps(ii).covError_boots = [D.hyps(ii).covError_boots; ...
        D.hyps(ii).covError];
    D.hyps(ii).covErrorShape_boots = [D.hyps(ii).covErrorShape_boots; ...
        D.hyps(ii).covErrorShape];
    D.hyps(ii).covErrorOrient_boots = [D.hyps(ii).covErrorOrient_boots; ...
        D.hyps(ii).covErrorOrient];
    
    D.hyps(ii).errOfMeansByKin_boots = [...
        D.hyps(ii).errOfMeansByKin_boots; D.hyps(ii).errOfMeansByKin];
    D.hyps(ii).covErrorByKin_boots = [...
        D.hyps(ii).covErrorByKin_boots; D.hyps(ii).covErrorByKin'];
    D.hyps(ii).covErrorShapeByKin_boots = [...
        D.hyps(ii).covErrorShapeByKin_boots; D.hyps(ii).covErrorShapeByKin'];
    D.hyps(ii).covErrorOrientByKin_boots = [...
        D.hyps(ii).covErrorOrientByKin_boots; D.hyps(ii).covErrorOrientByKin'];
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
