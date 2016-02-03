function covRatio(hyps)

    ys = [hyps.covRatio];
    nms = {hyps.name};
    ys = real(ys);
    ix = ~isnan(ys) & ~isinf(ys) & ys < 1/eps;
    ys = ys(ix); nms = nms(ix);
    
    lw = 3;
    bar(1:numel(ys), ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], ...
        'LineWidth', lw, 'BaseValue', 1);
    hold on;
    plot([0 numel(ys)+1], [1 1], 'k-', 'linewidth', 3);
    
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', 14);
    set(gcf, 'color', 'w');    

    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')
    set(gca, 'XTickLabelRotation', 45);
    
    set(gca, 'YScale', 'log');
    set(gca,'YMinorTick','off');
%     set(gca, 'YTick', 10.^(-4:2));
    axis([0 numel(nms)+1 10^-1 10^1]);
    
    ylabel('Covariance ratio');

end
