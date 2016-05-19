function marginalDists(Zs, Xs, grps, opts)
    if nargin < 4
        opts = struct();
    end    
    defopts = struct('oneKinPerFig', true, 'oneColPerFig', true, ...
        'showSe', true, 'clrs', [], 'tightXs', true);
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

    if ~opts.oneKinPerFig
        figure; set(gcf, 'color', 'w');
        ncols = ngrps;
        nrows = nfeats;
    end
    
    C = 0;
    for jj = 1:ngrps
        if isnan(grps(jj))
            continue;
        end
        if opts.oneKinPerFig && ~opts.oneColPerFig
            figure; set(gcf, 'color', 'w');
            ncols = ceil(sqrt(nfeats));
            nrows = ceil(nfeats/ncols);
            C = 0;
        end
        for ii = 1:nfeats
            if ~opts.oneColPerFig
                C = C + 1;
                subplot(ncols, nrows, C); hold on;
            else
                figure; set(gcf, 'color', 'w'); hold on;
            end
            xs = Xs{jj}(:,ii);
            ixmna = inf; ixmxa = -inf;
            
            for kk = 1:nitems
                ys = Zs{kk}{jj}(:,ii);
                
                ixmn = find(ys~=0, 1, 'first');
                ixmx = find(ys~=0, 1, 'last');
                ixmna = min(ixmna, ixmn); ixmxa = max(ixmxa, ixmx);
                
                clr = clrs(kk,:);
                plot(xs, ys, '-', 'Color', clr);
                
                ylm = [min(ys) max(ys)];
                mu = mean(ys);
                cps = cumsum(ys/sum(ys));
                mn = xs(find(cps > 0.25, 1, 'first'));
                mx = xs(find(cps > 0.75, 1, 'first'));
                plot([mu mu], 0.2*ylm, 'Color', clr);
                if opts.showSe
                    plot([mn mn], ylm, 'Color', clr);
                    plot([mx mx], ylm, 'Color', clr);
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

        end
    end
end
