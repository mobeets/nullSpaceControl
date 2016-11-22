function figs = marginalDists(Zs, Xs, grps, opts, nms)
    if nargin < 4
        opts = struct();
    end    
    defopts = struct('oneKinPerFig', true, 'oneColPerFig', false, ...
        'showSe', true, 'clrs', [], 'tightXs', true, 'ttl', '', ...
        'smoothing', 0, 'LineWidth', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % check defaults
    nitems = numel(Zs);
    assert(isa(Zs, 'cell'));
    assert(isa(Xs, 'cell'));
    if all(isempty(opts.clrs))
        clrs = cbrewer('qual', 'Set1', nitems);
    else
        clrs = opts.clrs;
    end
    [nbins, nfeats] = size(Zs{1}{1});
    ngrps = numel(grps);

    figs = [];
    if ~opts.oneKinPerFig && ~opts.oneColPerFig
        fig = figure; set(gcf, 'color', 'w'); figs = [figs fig];        
        ncols = sum(~isnan(grps));
        nrows = nfeats;
    end
    ymxs = max(max(cell2mat(cat(1, Zs{:}))));

    C = 0;
    d = 0;
    muc = nan;
%     ixmna = inf; ixmxa = -inf;
%     ymn = inf; ymx = -inf;
    for jj = 1:ngrps
        if isnan(grps(jj))
            continue;
        end
        d = d + 1;
        if opts.oneKinPerFig && ~opts.oneColPerFig
            fig = figure; set(gcf, 'color', 'w'); figs = [figs fig];
%             ncols = ceil(sqrt(nfeats));
%             nrows = ceil(nfeats/ncols);
            ncols = floor(nfeats/2);
            nrows = ceil(nfeats/ncols);
            ncols = 1;
            nrows = nfeats;
            C = 0;
        end
%         ixmna = inf; ixmxa = -inf;
%         ymn = inf; ymx = -inf;
        for ii = 1:nfeats
            if ~opts.oneColPerFig
                C = C + 1;
                subplot(ncols, nrows, C); hold on;
            elseif opts.oneKinPerFig
                fig = figure; set(gcf, 'color', 'w'); hold on;
                figs = [figs fig];
                if ~isempty(opts.ttl)
                    title(opts.ttl);
                end
            else
                if numel(figs) < nfeats
                    fig = figure; set(gcf, 'color', 'w'); hold on;
                    figs = [figs fig];
                    if ~isempty(opts.ttl)
                        title(opts.ttl);
                    end
                else
                    figure(figs(ii).Number);
                end
                nrows = ngrps;
                ncols = 1;
                if nrows > 8
                    nrows = floor(ngrps/4);
                    ncols = ceil(ngrps/nrows);
                end
                featSubplotInds = reshape(1:ngrps, nrows, ncols)';
                featSubplotInds = featSubplotInds(:);
                subplot(ncols, nrows, featSubplotInds(jj)); hold on;
            end            
            xs = Xs{jj}(:,ii);
            ixmna = inf; ixmxa = -inf;
            ymn = inf; ymx = -inf;
            
            for kk = 1:nitems
                ys = Zs{kk}{jj}(:,ii);                
                ixmn = find(ys~=0, 1, 'first');
                ixmx = find(ys~=0, 1, 'last');
                ixmn = find(cumsum(ys)/sum(ys) >= 0.025, 1);
                ixmx = find(cumsum(ys)/sum(ys) >= 0.975, 1);
                ixmna = min(ixmna, ixmn); ixmxa = max(ixmxa, ixmx);
                
                clr = clrs(kk,:);
                if ~isnan(opts.smoothing) && opts.smoothing > 0
                    ys = smooth(ys, opts.smoothing);
                end
                plot(xs, ys, '-', 'Color', clr, 'LineWidth', opts.LineWidth);
                
                ymn = min(min(ys), ymn); ymx = max(max(ys), ymx);
                ylm = [ymn ymx];
                cps = cumsum(ys/sum(ys));
                lastMu = muc;
                muc = sum(xs.*ys/sum(ys));
                mn = xs(find(cps >= 0.1, 1, 'first'));
                mx = xs(find(cps >= 0.9, 1, 'first'));
                
                mn = xs(find(ys > 0, 1, 'first'));
                mx = xs(find(ys > 0, 1, 'last'));
%                 plot([mn mn], ylm, 'Color', clr);
%                 plot([mx mx], ylm, 'Color', clr);
                    
                if opts.showSe
%                     plot([mn mn], ylm, 'Color', clr);
%                     plot([mx mx], ylm, 'Color', clr);
                    yv = ((kk-0.5)/nitems)*ylm(2);
                    plot([mn mx], [yv yv], 'Color', clr);
                    plot(muc, yv, 'o', 'Color', clr);
%                     [mn mx xs(find(cps >= 0.5, 1, 'first')) mu sum(ys)]
                else
                    t=1;
%                     plot([muc muc], 0.2*ylm, 'Color', clr, 'LineWidth', 2);
%                     plot([muc muc], [0 1], 'Color', clr, 'LineWidth', 2);
                end
                ylim([0 ymxs])
%                 ylim([0 1]);
            end
            
            if opts.tightXs
                xlim([xs(max(ixmna-1, 1)) xs(min(ixmxa+1, numel(xs)))]);
            end
            
%             xlim([-5 5]);
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            if d == 1 || opts.oneKinPerFig
                title(['dim ' num2str(ii) ''], 'FontWeight','Normal');
            elseif ~opts.oneColPerFig
%                 title(['Y^n(' num2str(ii) ')']);
                title('');
            end
            if (ii == 1 || opts.oneColPerFig) && ~opts.oneKinPerFig
                ylabel(['(\theta = ' num2str(grps(jj)) ')']);
                ylabel('');
            end
            if ii == 1 && ~isempty(opts.ttl) && ~opts.oneKinPerFig
                title(opts.ttl);
            end
        end
        % add legend to last panel, if empty
        if opts.oneKinPerFig && ~opts.oneColPerFig && ...
                C < ncols*nrows && ~isempty(nms)
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
