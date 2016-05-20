function barByHyp(ys, nms, ylbl, errL, errR)
    if nargin < 3
        ylbl = '';
    end
    if nargin < 4
        errL = [];
    end
    if nargin < 5
        errR = errL;
    end
    
    lw = 3;
    FontSize = 18;
    
    hold on;
    bar(ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', lw);
    if ~isempty(errL)
%         eb = errorbar(1:numel(nms), ys, ys-errL, errR-ys, 'k.', 'Linewidth', lw);
        line([1:numel(nms); 1:numel(nms)], [ys-errL; ys+errR], ...
            'LineWidth', lw, 'Color', 'k');
    end
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', FontSize);
    set(gcf, 'color', 'w');    

    if max(ys) > 1
        ytcks = unique(ceil(get(gca, 'YTick')));        
        set(gca,'YTick', ytcks);
    end
    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')
    set(gca, 'XTickLabelRotation', 45);
    ylabel(ylbl);

end
