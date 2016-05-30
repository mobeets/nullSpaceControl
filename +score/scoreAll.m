function D = scoreAll(D, opts, histopts)
    if nargin < 2
        opts = struct();
    end
    if nargin < 3
        histopts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'idxFldNm', '', ...
        'scoreGrpNm', 'thetaActualGrps', 'doBoots', true, ...
        'baseHypNm', 'observed', 'scoreBlkInd', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~strcmp(opts.decoderNm, 'fDecoder')
        warning(['Predicting null activity using "' opts.decoderNm '"']);
    end

    % compute null activity means/covs and marginal histograms
    B = D.blocks(opts.scoreBlkInd);
    NB = B.(opts.decoderNm).NulM2;
    Xs = []; grps = [];    
    
    for ii = 1:numel(D.hyps)
        [D.hyps(ii).nullActivity, gs] = nullActivityAll(...
            D.hyps(ii).latents, B, NB, opts);
    end
    
    % set default bin size using heuristic
    if ~isfield(histopts, 'nbins')        
        Y = pred.getHyp(D, opts.baseHypNm).nullActivity.zNull;
        nb = round(median(max(range(Y))./(2*iqr(Y)/size(Y,1)^(1/3))));
        histopts.nbins = nb;
    end

    % make and score marginal histograms
    for ii = 1:numel(D.hyps)
        YN = D.hyps(ii).nullActivity.zNull;
        [D.hyps(ii).marginalHist, Xs, grps] = makeHists(YN, gs, Xs, ...
            grps, histopts);
        D.hyps(ii).grps = grps;
    end
    [H, hind] = pred.getHyp(D, opts.baseHypNm);
    Y = H.nullActivity.zNull;
    baseErr = score.baseHistError(Y, Xs, gs, histopts);
    D.hyps(hind).marginalHist.baseErr = baseErr;
    
    % score hypotheses' predictions of null activity means/covs and hists
    objs = score.scoreNullActivity(D, opts);
    D = score.appendScores(D, objs, 'scores');
    % combine scores (with repetitions) into avg score obj
    D = score.summarizeScores(D);
end

function [sc, gs] = nullActivityAll(latents, B, NB, opts)
    idxFld = opts.idxFldNm;
    gs = B.(opts.scoreGrpNm);
    
    if ~isempty(idxFld) && isfield(B, idxFld) && ~isempty(B.(idxFld))
        ix = B.(idxFld);
        if numel(ix) ~= numel(gs)
            [numel(ix) numel(gs)]
            error([idxFld ' is not the same size as thetas']);
        end
        gs = gs(ix);
        latents = latents(ix,:);
    end
    sc = struct();
    if isempty(latents)
        sc.zNull = []; sc.zMu = {}; sc.zCov = {}; sc.zNullBin = {};
        return;
    end
    sc.zNull = latents*NB;
    [sc.zMu, sc.zCov, sc.zNullBin, sc.grps] = pred.avgByThetaGroup(sc.zNull, gs);
end

function [sc, Xs, grps] = makeHists(YN, gs, Xs, grps, opts)
    if nargin < 5
        opts = struct();
    end
    if isempty(Xs)
        [Zs, Xs, grps] = tools.marginalDist(YN, gs, opts);
    else
        Zs = tools.marginalDist(YN, gs, opts, Xs);
    end
    sc = struct();
    sc.Zs = Zs;
    sc.Xs = Xs;
    sc.grps = grps;
end

