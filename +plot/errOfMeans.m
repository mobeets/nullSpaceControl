function errOfMeans(hyps)

    ys = [hyps.errOfMeans];
    nms = {hyps.name};
    
    lw = 3;
    bar(ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', lw);
%     eh = errorbar(1:numel(nms), ys, errL, errR, 'k.', 'Linewidth', lw);
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', 14);
    set(gcf, 'color', 'w');
    title('average error in means');

    set(gca,'YTick', 0:ceil(ys));
    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')

end
