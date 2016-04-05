function errOfMeans(hyps, nm)
    if nargin < 2
        nm = '';
    end

    ys = [hyps.errOfMeans];
    nms = {hyps.name};
    
    lw = 3;
    bar(ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', lw);
%     eh = errorbar(1:numel(nms), ys, errL, errR, 'k.', 'Linewidth', lw);
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', 18);
    set(gcf, 'color', 'w');    

    set(gca,'YTick', 0:ceil(max(ys)));
    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')
    set(gca, 'XTickLabelRotation', 45);
    
    ylabel('Error of means');
    title(nm);

end
