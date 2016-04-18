function marginals(Y1, Y2, gs1, gs2, opts)
    if nargin < 4 || isempty(gs2)
        gs2 = gs1;
    end
    if nargin < 5
        opts = struct();
    end
    defopts = struct('splitKinsByFig', false, ...
        'clr2', [200 37 6]/255, 'clr1', [22 79 134]/255, ...
        'h1', 0.2, 'h2', 0.2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    clr1 = opts.clr1;
    clr2 = opts.clr2;
    grps = sort(unique(gs2));    

    if ~opts.splitKinsByFig
        set(gcf, 'color', 'w');
        ncols = numel(grps);
        nrows = size(Y2,2);
    end

    mns = min([Y2; Y1]);
    mxs = max([Y2; Y1]);

    C = 0;
    for jj = 1:numel(grps)
        ix1 = grps(jj) == gs1;
        Y1c = Y1(ix1,:);
        ix2 = grps(jj) == gs2;
        Y2c = Y2(ix2,:);        

        if opts.splitKinsByFig
            figure;
            set(gcf, 'color', 'w');
            ncols = ceil(sqrt(size(Y2,2)));
            nrows = ceil(size(Y2,2)/ncols);
            C = 0;
        end
        
        for ii = 1:size(Y2,2)
            YR1c = Y1c(:,ii);
            YR2c = Y2c(:,ii);            
            C = C + 1;
            
            subplot(ncols,nrows,C); hold on;
            xs = linspace(mns(ii), mxs(ii));
            ysh = singleMarginal(YR1c, opts.h1, xs, clr1);
            ylm = [min(ysh) max(ysh)];
            singleMarginal(YR2c, opts.h2, xs, clr2, ylm);
            
            % histogram
            % [c,b] = hist(YR2c, 30); c = c./trapz(b,c);
            
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            xlabel(['YN_' num2str(ii)]);
            if ii == 1
                ylabel(['\theta = ' num2str(grps(jj))]);
            end

        end
    end
end

function ysh = singleMarginal(Y, h, xs, clr, ylm)
    if nargin < 5
        ylm = [];
    end

    % Blk1 kde        
    Phatfcn = ksdensity_nd(Y, h);
    ysh = Phatfcn(xs');
    if ~isempty(ylm)
        ysh = ysh*(ylm(2)/max(ysh));
    end
    plot(xs, ysh, '-', 'Color', clr); % normalize to ymx
    
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

