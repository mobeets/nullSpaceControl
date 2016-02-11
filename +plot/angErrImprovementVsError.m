function angErrImprovementVsError(B, ynm1, ynm2)
    if nargin < 2
        ynm1 = 'latents';
    end
    if nargin < 3
        ynm2 = '';
    end

    inds = prctile(B.trial_index, [30 70]);
    indEarly = inds(1); indLate = inds(2);
    ixEarly = B.trial_index < indEarly;
    ixLate = B.trial_index > indLate;

    gs = B.thetaGrps;
%     gs1 = B.thetaGrpsOG;
%     gs2 = gs;
    gs1 = gs(ixEarly);
    gs2 = gs(ixLate);
    
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));

    %%
    
    ys = B.angError;
    ys1 = ys(ixEarly);
    ys2 = ys(ixLate);
    
%     ys1 = B.angErrorOG;
%     ys2 = ys1;
%     gs2 = gs(ixEarly);
    
%     ys1 = -ys1;
%     ys2 = zeros(size(ys2));

    figure; set(gcf, 'color', 'w');
    subplot(1,2,1);
    hold on; box off; set(gca, 'FontSize', 14);
    for ii = 1:numel(grps)
        ix1 = (gs1 == grps(ii));
        ix2 = (gs2 == grps(ii));
        scatter(grps(ii), median(ys1(ix1)) - median(ys2(ix2)), 120, ...
            clrs(ii,:), 'o', 'filled');
%         scatter(median(ys1(ix1)), median(ys2(ix2)), 120, clrs(ii,:), 'o', 'filled');
    end
    plot(xlim, [0 0], 'k--');
    xlabel('\theta');
    ylabel('improvement in angError, early to late');
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabelRotation', 45);
    
    %%

%     gs1 = gs(ixEarly);
%     gs2 = gs(ixLate);
    xs = B.trial_index;
    YN = B.([ynm1 'Nul']);
    if isempty(ynm2)
        YNh = zeros(size(YN));
    else
        YNh = B.([ynm2 'Nul']);
    end
    YN1 = YN(ixEarly,:);
    YN2 = YN(ixLate,:);
    YNh1 = YNh(ixEarly,:);
    YNh2 = YNh(ixLate,:);
    
    YN1 = YN;
    YNh1 = YNh;
    gs1 = gs;
    YN2 = zeros(size(YN2));
    YNh2 = zeros(size(YNh2));
    
    ys = arrayfun(@(ii) norm(YNh(ii,:) - YN(ii,:)), 1:size(YN,1));

    subplot(1,2,2);
    hold on; box off; set(gca, 'FontSize', 14);
    for ii = 1:numel(grps)
        ix1 = (gs1 == grps(ii));
        ix2 = (gs2 == grps(ii));
        v1 = norm(mean(YN1(ix1,:)) - mean(YNh1(ix1,:)));
        v2 = norm(mean(YN2(ix2,:)) - mean(YNh2(ix2,:)));
%         scatter(v1, v2, 120, clrs(ii,:), 'o', 'filled');
        scatter(grps(ii), v1 - v2, 120, clrs(ii,:), 'o', 'filled');
        
%         ix = (gs == grps(ii));
%         plot(xs(ix), smooth(xs(ix), ys(ix), 300), 'Color', clrs(ii,:), 'LineWidth', 3);
    end
    plot(xlim, [0 0], 'k--');
%     legend(arrayfun(@(c) num2str(c), grps, 'uni', 0), 'Location', 'BestOutside');
    xlabel('\theta');
    ylabel(['||mean(' ynm1 ') - mean(' ynm2 ')||']);
    title([B.datestr ': norm(' ynm1 ' - ' ynm2 ')']);
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabelRotation', 45);

end
