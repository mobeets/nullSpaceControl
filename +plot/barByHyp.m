function barByHyp(ys, nms, ylbl, ttl, errBarNm, ysb)
    if nargin < 3
        ylbl = '';
    end
    if nargin < 4
        ttl = '';
    end
    if nargin < 5
        errBarNm = '';
    end
    if nargin < 6
        ysb = [];
    end
    
    lw = 3;
    FontSize = 18;
    if strcmpi(errBarNm, 'se') && ~isempty(ysb)
        [ys, errL, errR] = plot.getSeErrorBars(ysb);
    else
        errL = [];
    end
    
    hold on;
    bar(ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', lw);
    if ~isempty(errL)
%         eb = errorbar(1:numel(nms), ys, ys-errL, errR-ys, 'k.', 'Linewidth', lw);
        line([1:numel(nms); 1:numel(nms)], [errL; errR], ...
            'LineWidth', lw, 'Color', 'k');
    end
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', FontSize);
    set(gcf, 'color', 'w');    

    if max(ys) > 1
        set(gca,'YTick', 0:ceil(max(ys)));
    end
    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')
    set(gca, 'XTickLabelRotation', 45);
    
    ylabel(ylbl);
    title(ttl);

end
