function [Zs, Xs, grps] = marginalDist(Y, gs, opts, Xs0)
    if nargin < 3 || isempty(opts)
        opts = struct();
    end
    if nargin < 4
        Xs0 = [];
    end    
    defopts = struct('doHist', true, 'nbins', 20, 'h', 0.2, ...
        'sameLimsPerPanel', true, 'smoothing', 0, 'getCounts', false, ...
        'makeMax1', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    grps = sort(unique(gs));
    ngrps = numel(grps);
    nfeats = size(Y,2);

    mns = min(Y);% - range(Y)*0.5;
    mxs = max(Y);% + range(Y)*0.5;
%     mns = prctile(Y, 1);
%     mxs = prctile(Y, 99);
    Xs = cell(ngrps,1);
    Zs = cell(ngrps,1);

    for jj = 1:ngrps
        Zs{jj} = nan(opts.nbins, nfeats);
        Xs{jj} = nan(opts.nbins, nfeats);
        for ii = 1:nfeats
            if ~isempty(Xs0)
                xs = Xs0{jj}(:,ii);
            else                
                if opts.sameLimsPerPanel
                    xs = linspace(min(mns), max(mxs), opts.nbins);
                else
                    xs = linspace(mns(ii), mxs(ii), opts.nbins);
                end
            end
            Xs{jj}(:,ii) = xs;
            Zs{jj}(:,ii) = singleMarginal(Y(grps(jj) == gs,ii), xs, opts);
            if opts.makeMax1
                Zs{jj}(:,ii) = Zs{jj}(:,ii)/nanmax(Zs{jj}(:,ii));
            end
        end
    end
end

function ysh = singleMarginal(Y, xs, opts)
    if opts.doHist
        [c,b] = hist(Y, xs);
        if opts.getCounts
            ysh = c;
            return;
        end
        ysh = c./trapz(b,c);
    else
        Phatfcn = ksdensity_nd(Y, opts.h);
        ysh = Phatfcn(xs');
    end
    if opts.smoothing > 0
        ysh = smooth(ysh, opts.smoothing);
    end
end

