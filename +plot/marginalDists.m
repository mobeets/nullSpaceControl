function marginalDists(Zs, Xs, grps, opts)
    if nargin < 4
        opts = struct();
    end    
    defopts = struct('splitKinsByFig', true, 'showSe', true, ...
        'clrs', []);
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

    if ~opts.splitKinsByFig
        figure; set(gcf, 'color', 'w');
        ncols = ngrps;
        nrows = nfeats;
    end
    
    C = 0;
    for jj = 1:numel(grps)
        if opts.splitKinsByFig
            figure; set(gcf, 'color', 'w');
            ncols = ceil(sqrt(nfeats));
            nrows = ceil(nfeats/ncols);
            C = 0;
        end
        for ii = 1:nfeats            
            C = C + 1;
            subplot(ncols, nrows, C); hold on;
            xs = Xs{jj}(:,ii);
            
            for kk = 1:nitems
                ys = Zs{kk}{jj}(:,ii);
                clr = clrs(kk,:);
                plot(xs, ys, '-', 'Color', clr);
                
                ylm = [min(ys) max(ys)];
                mu = mean(ys);
                cps = cumsum(ys/sum(ys));
                mn = xs(find(cps > 0.25, 1, 'first'));
                mx = xs(find(cps > 0.75, 1, 'first'));
                plot([mu mu], 0.2*ylm, 'Color', clr);
                plot([mn mn], ylm, 'Color', clr);
                plot([mx mx], ylm, 'Color', clr);                
            end

%             ylm = [];
%             for kk = 1:nitems
%                 YRc = Ys{kk}(grps(jj) == gs{kk},ii);
%                 ysh = singleMarginal(YRc, opts.hs(kk), xs, clrs(kk,:), ...
%                     ylm, opts);
%                 Zs{jj,ii}(kk,:) = ysh;
%                 ylm = [min(ysh) max(ysh)];
%             end
            
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
        ysh = c;
        plot(xs, ysh, '-', 'Color', clr);
    end
    
    % show bounds
    mu = mean(Y);
    if opts.showSe
        cps = cumsum(ysh/sum(ysh));
        mn = xs(find(cps > 0.25, 1, 'first'));
        mx = xs(find(cps > 0.75, 1, 'first'));
    else
        mn = min(Y); mx = max(Y);
    end    
    if isempty(ylm)
        ylm = [min(ysh) max(ysh)];
    end
    rng = range(Y);
%     icdf = ksdensity_nd_icdf(Phatfcn, linspace(mn - rng/2, mx + rng/2, 1000));
%     mn = icdf(0.01); mx = icdf(0.99);
    plot([mn mn], ylm, 'Color', clr);
    plot([mx mx], ylm, 'Color', clr);
    plot([mu mu], 0.2*ylm, 'Color', clr);

end

