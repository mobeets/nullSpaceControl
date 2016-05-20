function D = scoreAll(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'idxFldNm', '', ...
        'scoreGrpNm', 'thetaActualGrps16', 'doBoots', true, ...
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
        YN = D.hyps(ii).nullActivity.zNull;
        [D.hyps(ii).marginalHist, Xs, grps] = histErrors(YN, gs, Xs, grps);
        D.hyps(ii).grps = grps;
    end
    % score hypotheses' predictions of null activity means/covs and hists
    objs = score.scoreNullActivity(D, opts);
    D = score.appendScores(D, objs, 'scores');
    % combine scores (with repetitions) into avg score obj
    D = score.summarizeScores(D);
end

function [sc, gs] = nullActivityAll(latents, B, NB, opts)
    idxFld = opts.idxFldNm;
    grpFld = opts.scoreGrpNm;
    
    gs = B.(grpFld);
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

function [sc, Xs, grps] = histErrors(YN, gs, Xs, grps)
    if isempty(Xs)
        [Zs, Xs, grps] = tools.marginalDist(YN, gs);
    else
        Zs = tools.marginalDist(YN, gs, [], Xs);
    end
    sc = struct();
    sc.Zs = Zs;
    sc.Xs = Xs;
    sc.grps = grps;
end

