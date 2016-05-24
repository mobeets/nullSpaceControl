function figs = marginalDists(Zs, Xs, grps, opts, nms)
    if nargin < 4
        opts = struct();
    end    
    defopts = struct('oneKinPerFig', true, 'oneColPerFig', false, ...
        'showSe', true, 'clrs', [], 'tightXs', true, 'ttl', '', ...
        'smoothing', 0);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % check defaults
    nitems = numel(Zs);
    assert(isa(Zs, 'cell'));
    assert(isa(Xs, 'cell'));
    if all(isempty(opts.clrs))
        clrs = cbrewer('qual', 'Set1', nitems);
    end
    [nbins, nfeats] = size(Zs{1}{1});
    ngrps = numel(grps);

    figs = [];
    if ~opts.oneKinPerFig
        fig = figure; set(gcf, 'color', 'w'); figs = [figs fig];        
        ncols = ngrps;
        nrows = nfeats;
    end
    
    C = 0;
    for jj = 1:ngrps
        if isnan(grps(jj))
            continue;
        end
        if opts.oneKinPerFig && ~opts.oneColPerFig
            fig = figure; set(gcf, 'color', 'w'); figs = [figs fig];
            ncols = ceil(sqrt(nfeats));
            nrows = ceil(nfeats/ncols);
            C = 0;
        end
        for ii = 1:nfeats
            if ~opts.oneColPerFig
                C = C + 1;
                subplot(ncols, nrows, C); hold on;
            else
                fig = figure; set(gcf, 'color', 'w'); hold on;
                figs = [figs fig];
                if ~isempty(opts.ttl)
                    title(opts.ttl);
                end
            end            
            xs = Xs{jj}(:,ii);
            ixmna = inf; ixmxa = -inf;
            ymn = inf; ymx = -inf;
            
            for kk = 1:nitems
                ys = Zs{kk}{jj}(:,ii);
                
                ixmn = find(ys~=0, 1, 'first');
                ixmx = find(ys~=0, 1, 'last');
                ixmna = min(ixmna, ixmn); ixmxa = max(ixmxa, ixmx);
                
                clr = clrs(kk,:);
                if ~isnan(opts.smoothing) && opts.smoothing > 0
                    ys = smooth(ys, opts.smoothing);
                end
                plot(xs, ys, '-', 'Color', clr);
                
                ymn = min(min(ys), ymn); ymx = max(max(ys), ymx);
                ylm = [ymn ymx];
                cps = cumsum(ys/sum(ys));
                mu = sum(xs.*ys/sum(ys));
                mn = xs(find(cps >= 0.1, 1, 'first'));
                mx = xs(find(cps >= 0.9, 1, 'first'));                
                if opts.showSe
%                     plot([mn mn], ylm, 'Color', clr);
%                     plot([mx mx], ylm, 'Color', clr);
                    yv = ((kk-0.5)/nitems)*ylm(2);
                    plot([mn mx], [yv yv], 'Color', clr);
                    plot(mu, yv, 'o', 'Color', clr);
%                     [mn mx xs(find(cps >= 0.5, 1, 'first')) mu sum(ys)]
                else
                    plot([mu mu], 0.2*ylm, 'Color', clr);
                end
            end
            
            if opts.tightXs
                xlim([xs(ixmna) xs(ixmxa)]);
            end
            
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            xlabel(['YN_' num2str(ii)]);
            if ii == 1 || opts.oneColPerFig
                ylabel(['\theta = ' num2str(grps(jj))]);
            end
            if ii == 1 && ~isempty(opts.ttl)
                title(opts.ttl);
            end
        end
        % add legend to last panel, if empty
        if ~opts.oneColPerFig && C < ncols*nrows && ~isempty(nms)
            subplot(ncols, nrows, C + 1); hold on;
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            axis off;
            for kk = 1:nitems
                clr = clrs(kk,:);
                plot(0,0, 'Color', clr);
            end
            plot(0,0,'ow');
            legend(nms);
            legend boxoff;
        end
    end
end
