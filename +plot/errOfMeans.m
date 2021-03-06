function errOfMeans(hyps, nm, errBarNm)
    if nargin < 2
        nm = '';
    end
    if nargin < 3
        errBarNm = '';
    end
    
    ys = [hyps.errOfMeans];
    nms = {hyps.name};
    lw = 3;
    FontSize = 18;
    if strcmpi(errBarNm, 'se')
        [ys, errL, errR] = plot.getSeErrorBars({hyps.errOfMeans_boots});
    else
        errL = [];
    end
    
    hold on;
    bar(ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', lw);
    if ~isempty(errL)
        eh = errorbar(1:numel(nms), ys, ys-errL, errR-ys, 'k.', 'Linewidth', lw);
    end
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', FontSize);
    set(gcf, 'color', 'w');    

    set(gca,'YTick', 0:ceil(max(ys)));
    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')
    set(gca, 'XTickLabelRotation', 45);
    
    ylabel('Error of means');
    title(nm);

end
