function objs = scoreNullActivity(D, opts)
    defopts = struct('doBoots', true, 'baseHypNm', 'observed', ...
        'scoreBlkInd', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~isfield(D.hyps(1), 'errOfMeans')
    end

%     ix = strcmp(baseHypNm, {D.hyps.name});
%     actual = D.hyps(ix).null(bind);
    H = pred.getHyp(D, opts.baseHypNm);
    actual = H.nullActivity;
    zNull = actual.zNullBin;
    zMu = actual.zMu;
    zCov = actual.zCov;
    zHist = H.marginalHist.Zs;
    zKde = H.jointKde.ps;
    
    objs = [];
    for ii = 1:numel(D.hyps)
        obj = struct();
        obj.name = D.hyps(ii).name;
        obj.grps = D.hyps(ii).nullActivity.grps;
        if isempty(D.hyps(ii).timestamp)
            warning(['No timestamp for ' D.hyps(ii).name]);
        end
        obj.timestamp = D.hyps(ii).timestamp;
        
        hyp = D.hyps(ii).nullActivity;
        zNull0 = hyp.zNullBin;
        zMu0 = hyp.zMu;
        zCov0 = hyp.zCov;
        zHist0 = D.hyps(ii).marginalHist.Zs;
        zKde0 = D.hyps(ii).jointKde.ps;
        
        if strcmp(D.hyps(ii).name, opts.baseHypNm) || isempty(zMu0)            
            objs = fillEmptyFields(objs, obj);
            objs = [objs obj];
            continue;
        end
        
        if isequal(size(cell2mat(zNull)), size(cell2mat(zNull0)))
            obj.errOfMeansFull = score.errOfMeans(zNull, zNull0);
        else
            obj.errOfMeansFull = nan;
        end
        obj.errOfMeansByKinByCol = abs(cell2mat(zMu') - cell2mat(zMu0'))';
        [obj.errOfMeans, e2, e3] = score.errOfMeans(zMu, zMu0);
        obj.pctErrOfMeansByKin = e3; % pct of norm captured
        obj.errOfMeansByKin = e2; % errs by mean
        obj.covRatio = score.covRatio(zCov, zCov0);
        [s, s2, s3, S,S2,S3] = score.covError(zNull, zNull0);
        obj.covError = s;
        obj.covErrorOrient = s2;
        obj.covErrorShape = s3;
        obj.covErrorByKin = S;
        obj.covErrorOrientByKin = S2;
        obj.covErrorShapeByKin = S3;
        
        histErr = score.histError(zHist, zHist0);
        obj.histErrByKinByCol = histErr;
        obj.histErrByKin = sum(histErr,2);
        obj.histErrByCol = sum(histErr,1)';
        obj.histErr = sum(histErr(:));
        
        kdeErr = score.jKdeError(zKde, zKde0);
        obj.kdeErrByKin = kdeErr;
        obj.kdeErr = sum(kdeErr);
        
        reportOutOfBounds(D.hyps(ii).latents, H.latents, D.hyps(ii).name);
        objs = fillEmptyFields(objs, obj);
        objs = [objs obj];
    end    
end

function X = fillEmptyFields(X, x)
    if ~isa(X, 'struct')
        return;
    end
    fns = setdiff(fieldnames(x), fieldnames(X));
    for ii = 1:numel(fns)
        X(1).(fns{ii}) = nan;
    end
end

function [isUndr, isOver, isEither] = reportOutOfBounds(Zh, Z, nm)
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
    
    if isEither > 0
        disp([nm ' hypothesis has ' num2str(isEither) ...
            ' points out of bounds (' num2str(isUndr) ' under, ' ...
            num2str(isOver) ' over).']);
    end
end
