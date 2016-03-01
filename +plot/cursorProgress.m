function cursorProgress(B, grpName, smth)
    if nargin < 3
        smth = 100;
    end
    if nargin < 2 || isempty(grpName)
        grpName = 'thetaGrps';
    end
    gs = B.(grpName);
    grps = sort(unique(gs(~isnan(gs))));
    
    xs = B.trial_index;
    ys = B.progress;
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    xsa = unique(xs);
    
    ymn = floor(min(ys)); ymx = ceil(max(ys));

    set(gcf, 'color', 'w');
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        ysc = ys(ix);
        xsc = xs(ix);
        subplot(2,4,jj); hold on; set(gca, 'FontSize', 14);
%         plot(xsc - min(xsc), ysc, '.', 'Color', clrs(jj,:));
        for ii = 1:numel(xsa)
            plot(xsa(ii), nanmean(ysc(xsc == xsa(ii))), '.', 'Color', clrs(jj,:));
        end
        plot(xsc, smooth(xsc, ysc, smth), 'k-');%, 'Color', clrs(jj,:));
%         ylim([-15 15]);
        xlim([floor(min(xs)) ceil(max(xs))]);
        ylim([ymn ymx]);
    end
    xlabel('time');
    ylabel('cursor progress');

end
