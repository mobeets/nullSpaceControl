function [D, opts] = fitAndPlotMarginals(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('nbins', nan, 'doFit', false, 'hypInds', [], ...
        'grpsToShow', [], 'ttl', D.datestr, 'showSe', false, ...
        'grpNm', 'thetaActualGrps');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if isempty(opts.hypInds)
        error('Must set opts.hypInds');
    end
    if ~isnan(opts.nbins) && ~opts.doFit
        warning('nbins is set but not doFit.');
    end
    
    gs = D.blocks(2).(opts.grpNm);
    if isnan(opts.nbins)
        Y = D.hyps(1).nullActivity.zNull;
        opts.nbins = score.optimalBinCount(Y, gs, false);
    end
    
    % make and score marginal histograms
    if opts.doFit
        Xs = [];
        for ii = 1:numel(D.hyps)
            YN = D.hyps(ii).nullActivity.zNull;
            if isempty(Xs)
                [Zs, Xs, grps] = tools.marginalDist(YN, gs, opts);
            else
                Zs = tools.marginalDist(YN, gs, opts, Xs);
            end
            D.hyps(ii).marginalHist.Zs = Zs;
            D.hyps(ii).marginalHist.Xs = Xs;
            D.hyps(ii).marginalHist.grps = grps;
        end
    end

    % plot marginal hists    
    Hs = D.hyps(opts.hypInds);
    if isfield(Hs(1).marginalHist, 'baseErr')
        Hs(1).marginalHist = rmfield(Hs(1).marginalHist, 'baseErr');
    end
    hists = [Hs.marginalHist];
    grps = hists(1).grps;
    Xs = hists(1).Xs;
    Zs = {hists.Zs};

    if ~isempty(opts.grpsToShow)
        grps(~ismember(grps, opts.grpsToShow)) = nan;
    end
    plot.marginalDists(Zs, Xs, grps, opts, {Hs.name});

end
