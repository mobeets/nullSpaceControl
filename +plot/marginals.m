function marginals(Ys, gs, opts)
    if nargin < 3
        opts = struct();
    end    
    defopts = struct('splitKinsByFig', false, 'doHistOnly', false, ...
        'clrs', [], 'hs', 0.2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    % check defaults
    nitems = numel(Ys);
    assert(isa(Ys, 'cell'));
    if ~isa(gs, 'cell')
        tmp = repmat(gs, 1, nitems);
        gs = num2cell(tmp, 1);
    end
    if all(isempty(opts.clrs))
        clrs = cbrewer('qual', 'Set1', nitems);
    end
    if numel(opts.hs) == 1
        opts.hs = opts.hs*ones(nitems,1);
    end
    grps = sort(unique(gs{1}));
    nfeats = size(Ys{1},2);

    if ~opts.splitKinsByFig
        figure;
        set(gcf, 'color', 'w');
        ncols = numel(grps);
        nrows = size(Ys{1},2);
    end

    allYs = cell2mat(Ys');
    mns = min(allYs);
    mxs = max(allYs);

    C = 0;
    for jj = 1:numel(grps)
        if opts.splitKinsByFig
            figure;
            set(gcf, 'color', 'w');
            ncols = ceil(sqrt(nfeats));
            nrows = ceil(nfeats/ncols);
            C = 0;
        end
        for ii = 1:nfeats            
            C = C + 1;
            subplot(ncols, nrows, C); hold on;
            xs = linspace(min(mns), max(mxs));
%             xs = linspace(mns(ii), mxs(ii));

            ylm = [];
            for kk = 1:nitems
                YRc = Ys{kk}(grps(jj) == gs{kk},ii);
                ysh = singleMarginal(YRc, opts.hs(kk), xs, clrs(kk,:), ...
                    ylm, opts);
                ylm = [min(ysh) max(ysh)];
            end
            
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            xlabel(['YN_' num2str(ii)]);
            if ii == 1
                ylabel(['\theta = ' num2str(grps(jj))]);
            end

        end
    end
end

function ysh = singleMarginal(Y, h, xs, clr, ylm, opts)
    if nargin < 5 || isempty(ylm)
        ylm = [];
    end

    % Blk1 kde        
    Phatfcn = ksdensity_nd(Y, h);
    ysh = Phatfcn(xs');
    if ~isempty(ylm)
        ysh = ysh*(ylm(2)/max(ysh));
    end
    if ~opts.doHistOnly
        plot(xs, ysh, '-', 'Color', clr); % normalize to ymx
    end
    
    if opts.doHistOnly
        [c,b] = hist(Y, xs); c = c./trapz(b,c);
        plot(xs, c, '-', 'Color', clr);
    end
    
    % show bounds
    mu = mean(Y);
    mn = min(Y); mx = max(Y); rng = range(Y);
    if isempty(ylm)
        ylm = [min(ysh) max(ysh)];
    end
%     icdf = ksdensity_nd_icdf(Phatfcn, linspace(mn - rng/2, mx + rng/2, 1000));
%     mn = icdf(0.01); mx = icdf(0.99);
    plot([mn mn], ylm, 'Color', clr);
    plot([mx mx], ylm, 'Color', clr);
    plot([mu mu], 0.2*ylm, 'Color', clr);

end

