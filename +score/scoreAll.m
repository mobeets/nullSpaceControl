function D = scoreAll(D, opts, histopts)
    if nargin < 2
        opts = struct();
    end
    if nargin < 3
        histopts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'idxFldNm', '', ...
        'scoreGrpNm', 'thetaActualGrps', 'doBoots', true, ...
        'baseHypNm', 'observed', 'scoreBlkInd', 2, 'jointKdeDimNo', 2, ...
        'nullCols', nan);
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
            D.hyps(ii).latents, B, NB, opts, D);
    end
    
    % set default bin size using heuristic
    if ~isfield(histopts, 'nbins')        
        Y = pred.getHyp(D, opts.baseHypNm).nullActivity.zNull;
        nb = score.optimalBinCount(Y, gs, false);
%         nb = round(median(max(range(Y))./(2*iqr(Y)/size(Y,1)^(1/3))));
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
    
    % make and score joint kdes using first ds of null activity
    [H, ~] = pred.getHyp(D, opts.baseHypNm);
    Z1 = H.nullActivity.zNull;
    if opts.jointKdeDimNo == 2 && size(Z1,2) >= 2
        [u,s,v] = svd(Z1);
        v = v(:,1:opts.jointKdeDimNo); % 2d probably
        ngrps = numel(H.nullActivity.zNullBin);
        for ii = 1:numel(D.hyps)
            D.hyps(ii).jointKde.ps = cell(ngrps,1);
            D.hyps(ii).jointKde.bw = cell(ngrps,1);
            D.hyps(ii).jointKde.xs = cell(ngrps,1);
            D.hyps(ii).jointKde.ys = cell(ngrps,1);
        end
        for jj = 1:ngrps
            Z1 = H.nullActivity.zNullBin{jj}*v;
            Zs = arrayfun(@(ii) D.hyps(ii).nullActivity.zNullBin{jj}*v, ...
                2:numel(D.hyps), 'uni', 0);
            [P1, Ps, X, Y, bw] = score.compareKde(Z1, Zs, true);
            for ii = 1:numel(D.hyps)
                if ii == 1
                    Pc = P1;
                    xs = X; ys = Y;
                else
                    Pc = Ps{ii-1};
                    xs = []; ys = [];
                end
                D.hyps(ii).jointKde.ps{jj} = Pc;
                D.hyps(ii).jointKde.bw{jj} = bw;
                D.hyps(ii).jointKde.xs{jj} = xs;
                D.hyps(ii).jointKde.ys{jj} = ys;
            end
        end
    end
    
    % score hypotheses' predictions of null activity means/covs and hists
    objs = score.scoreNullActivity(D, opts);
    D = score.appendScores(D, objs, 'scores');
    % combine scores (with repetitions) into avg score obj
    D = score.summarizeScores(D);
end

function [sc, gs] = nullActivityAll(latents, B, NB, opts, D)
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
    
    if ~any(isnan(opts.nullCols)) && ~isempty(opts.nullCols)
        sc.zNull = sc.zNull(:, opts.nullCols);
    end
    
%     warning('setting latents with bad spikes to nan');
%     [isOutOfBoundsFcn, ~] = pred.boundsFcn(nan, 'spikes', D);
%     ixBad = isOutOfBoundsFcn(latents);
%     latents = latents(~ixBad,:);
% %     gs = gs(~ixBad);
    
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

function defaultBinSize(YN, gs)

    Y = D.hyps(1).nullActivity.zNull;
    score.optimalBinCount(Y, gs, true)

end
