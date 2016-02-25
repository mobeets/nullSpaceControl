function cursorProgress(D)

    xs = D.trials.trial_index;
    ys = D.trials.progress;
    gs = D.trials.thetaGrps;
    grps = sort(unique(gs(~isnan(gs))));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
%     xsa = unique(xs);

    close all;
    figure; set(gcf, 'color', 'w');
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        ysc = ys(ix);
        xsc = xs(ix);
        subplot(2,4,jj); hold on;
    %     for ii = 1:numel(xsa)
    %         plot(xsa(ii), nanmean(ysc(xsc == xsa(ii))), '.', 'Color', clrs(jj,:));
    %     end
        plot(xsc, smooth(xsc, ysc, 100), '-', 'Color', clrs(jj,:));
        ylim([-10 10]);
    end

end
