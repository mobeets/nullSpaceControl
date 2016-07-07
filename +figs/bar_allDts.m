function bar_allDts(S, nms, dts, clrs, ylbl)

    % for ii = 1:numel(nmsC)
    %     plot(1:numel(dts), SC(:,ii), '.-', 'LineWidth', 3, 'MarkerSize', 40);
    % end
    brs = bar(1:numel(dts), S, 'FaceColor', clrs(1,:));
    for ii = 1:numel(brs)
        brs(ii).FaceColor = clrs(ii,:);
    end    

    set(gca, 'XTick', 1:numel(dts));
    set(gca, 'XTickLabel', dts);
    set(gca, 'XTickLabelRotation', 45);
    ylabel(ylbl);
    legend(nms, 'Location', 'BestOutside');

end
