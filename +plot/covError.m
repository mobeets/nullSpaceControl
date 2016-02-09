function covError(hyps, nm, ynm)
    if nargin < 2
        nm = '';
    end
    if nargin < 3
        ynm = 'covError';
        ylbl = 'Error of covariance';
    else
        ylbl = ynm;
    end

    ys = [hyps.(ynm)];
    nms = {hyps.name};
    
    lw = 3;
    bar(ys, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', lw);
%     eh = errorbar(1:numel(nms), ys, errL, errR, 'k.', 'Linewidth', lw);
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'FontSize', 14);
    set(gcf, 'color', 'w');    

%     set(gca,'YTick', 0:ceil(max(ys)));
    set(gca,'LineWidth', lw);
    set(gca, 'box', 'off')
    set(gca, 'XTickLabelRotation', 45);
    
    ylabel(ylbl);
    title(nm);

end
