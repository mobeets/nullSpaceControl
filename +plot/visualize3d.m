function D = visualize(dtstr, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('showMu', true, 'showPts', true, 'doNull', true, ...
        'doColor', false, 'D', [], 'blockInd', 2, 'grpName', 'thetaGrps');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    if isempty(opts.D)
        D = io.quickLoadByDate(dtstr);
    else
        D = opts.D;
    end
    B = D.blocks(opts.blockInd);
    NB2 = B.fDecoder.NulM2;
    RB2 = B.fDecoder.RowM2;
    Y = B.latents;
    
    if opts.doNull
        [u,s,v] = svd(Y*NB2); NB2 = NB2*v;
        Y = Y*NB2;
    else
        [u,s,v] = svd(Y);
        Y = Y*v;
    end
    
    gs = B.(opts.grpName);
    grps = sort(unique(gs));
    
    figure; set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 18);
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        if opts.doColor
            clr = clrs(jj,:);
        else
            clr = 'k';
        end        
        if opts.showMu
            mu = mean(Y(ix,1:3));
            plot3(mu(1), mu(2), mu(3), 'ko', 'MarkerFaceColor', clr, ...
                'MarkerSize', 10);
        end
        if opts.showPts
            plot3(Y(ix,1), Y(ix,2), Y(ix,3), '.', 'Color', clr);
        end
    end
    plot3(0,0,0,'r.','MarkerSize',50);
    axis vis3d;
    title(D.datestr);
end
