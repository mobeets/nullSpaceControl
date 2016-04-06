function singleValByGrp(D, fcn, opts)

    B = D.blocks(opts.blockInd);
    Y = B.latents;
    if opts.doNull
        NB2 = B.fDecoder.NulM2;        
        Y = Y*NB2;
    end
    gs = B.(opts.grpName);
    grps = sort(unique(gs));
    vs = nan(numel(grps),1);
    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 18);
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        vs(jj) = fcn(Y(ix,:));        
    end
    plot(grps, vs, 'k-', 'LineWidth', 4);
    for jj = 1:numel(grps)
        plot(grps(jj), vs(jj), '.', 'Color', clrs(jj,:), ...
            'MarkerSize', 50);
    end
    xlabel('\theta');
    ylabel('value');
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabelRotation', 45);

end
