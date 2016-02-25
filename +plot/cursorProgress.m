function cursorProgress(B, smth)
    if nargin < 2
        smth = 100;
    end

    xs = B.trial_index;
    ys = B.progress;
    gs = B.thetaGrps;
    grps = sort(unique(gs(~isnan(gs))));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
%     xsa = unique(xs);

    set(gcf, 'color', 'w');
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        ysc = ys(ix);
        xsc = xs(ix);
        subplot(2,4,jj); hold on;
    %     for ii = 1:numel(xsa)
    %         plot(xsa(ii), nanmean(ysc(xsc == xsa(ii))), '.', 'Color', clrs(jj,:));
    %     end
        plot(xsc, smooth(xsc, ysc, smth), '-', 'Color', clrs(jj,:));
        ylim([-15 15]);
    end

end
