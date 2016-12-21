function [D, opts, figs] = fitAndPlotMarginals(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('nbins', nan, 'doFit', false, 'hypInds', [], ...
        'grpsToShow', [], 'ttl', D.datestr, 'showSe', false, ...
        'grpNm', 'thetaActualGrps', 'makeMax1', false, ...
        'oneColPerFig', false, 'oneKinPerFig', false, 'dimInds', [], ...
        'includeBlk1', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if isempty(opts.hypInds)
        error('Must set opts.hypInds');
    end
    if ~isnan(opts.nbins) && ~opts.doFit
        warning('nbins is set but not doFit.');
    end
    
    gs = D.blocks(2).(opts.grpNm);
    warning('DOING SOMETHING TEMPORARY');    
    RB = D.blocks(2).fDecoder.RowM2;
    YR = D.blocks(2).latents*RB;
    angs = arrayfun(@(t) tools.computeAngle(YR(t,:), [1; 0]), ...
        1:size(YR,1))'; angs = mod(angs, 360);
    gs = score.thetaGroup(angs, score.thetaCenters(16));

    if isnan(opts.nbins)
        YN = D.hyps(1).nullActivity.zNull;
%         YN = D.hyps(1).latents*RB;
%         YN = sqrt(sum(YN.^2,2));
        opts.nbins = score.optimalBinCount(YN, gs, false);
    end
    
    % make and score marginal histograms
    if opts.doFit
        Xs = [];
        for ii = opts.hypInds % 1:numel(D.hyps)
            YN = D.hyps(ii).nullActivity.zNull;
%             YN = D.hyps(ii).latents*RB;
%             YN = sqrt(sum(YN.^2,2));
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
    hnms = {Hs.name};
    
    if opts.includeBlk1
        Y1 = D.blocks(1).latents;
        NB = D.blocks(2).fDecoder.NulM2;
        [~,~,v] = svd(D.blocks(2).latents*NB); NB = NB*v;
        YN = Y1*NB;
%         YN = Y1*RB;
%         YN = sqrt(sum(YN.^2,2));
        RB = D.blocks(2).fDecoder.RowM2;
        YR = Y1*RB;
        angs = arrayfun(@(t) tools.computeAngle(YR(t,:), [1; 0]), ...
            1:size(YR,1))';
        angs = mod(angs, 360);
        gs1 = score.thetaGroup(angs, score.thetaCenters(16));
        Zs{end+1} = tools.marginalDist(YN, gs1, opts, Xs);
        hnms{end+1} = 'Blk1';
    end
    
    if ~isempty(opts.dimInds)
        fcn = @(x) x(:,opts.dimInds);
        Xs = cellfun(fcn, Xs, 'uni', 0);
        for ii = 1:numel(Zs)
            Zs{ii} = cellfun(fcn, Zs{ii}, 'uni', 0);
        end
    end
    
    % add Blk1
%     warning('Adding block 1');
%     NB = D.blocks(2).fDecoder.NulM2;
%     Y2 = D.blocks(2).latents;
%     [~,~,v] = svd(Y2*NB); NB = NB*v;
%     assert(isequal(Y2*NB, D.hyps(1).nullActivity.zNull));
%     YN1 = D.blocks(1).latents*NB;
%     Zs1 = tools.marginalDist(YN1, D.blocks(1).(opts.grpNm), opts, Xs);
%     Zs{numel(Zs)+1} = Zs1;
%     opts.clrs = [opts.clrs; [0.5 0.5 0.5]];

    if ~isempty(opts.grpsToShow)
        grps(~ismember(grps, opts.grpsToShow)) = nan;
    end
    figs = plot.marginalDists(Zs, Xs, grps, opts, hnms);

end
