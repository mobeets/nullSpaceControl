function valsByGrp(vs, grps, nms, clrs)
    if nargin < 3
        nms = {};
    end
    if nargin < 4
        clrs = [];
    end
    hold on;
    for ii = 1:size(vs,1)
        if ~isempty(clrs)
            plot(grps, vs(ii,:), '-o', 'Color', clrs(ii,:), 'LineWidth', 3);
        else
            plot(grps, vs(ii,:), '-o', 'LineWidth', 3);
        end
    end
    if ~isempty(nms)
        legend(nms);
        legend boxoff;
    end
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
    set(gca, 'XTickLabelRotation', 45);
end
