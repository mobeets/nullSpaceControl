function [D, opts] = fitAndPlotMarginals(D, opts)
    if nargin < 2
        opts = struct();
    end
    gs = D.blocks(1).thetaActualGrps;
    if ~isfield(opts, 'nbins') || isnan(opts.nbins)
        Y = D.hyps(1).nullActivity.zNull;
        opts.nbins = score.optimalBinCount(Y, gs, false);
    end

    % make and score marginal histograms
    if ~isfield(opts, 'doFit') || opts.doFit
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
    if ~isfield(opts, 'hypInds')
        return;
    end
    Hs = D.hyps(opts.hypInds);
    Hs(1).marginalHist = rmfield(Hs(1).marginalHist, 'baseErr');
    hists = [Hs.marginalHist];
    grps = hists(1).grps;
    Xs = hists(1).Xs;
    Zs = {hists.Zs};

    if isfield(opts, 'grpsToShow') && ~isempty(opts.grpsToShow)
        grps(~ismember(grps, opts.grpsToShow)) = nan;
    end
    if ~isfield(opts, 'ttl')
        opts.ttl = D.datestr;
    end
    if ~isfield(opts, 'showSe')
        opts.showSe = false;
    end
    plot.marginalDists(Zs, Xs, grps, opts, {Hs.name});

end
