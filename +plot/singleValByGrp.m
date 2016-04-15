function singleValByGrp(vs, grps, D, fcn, opts)
    if nargin > 2 && isempty(vs) && isempty(grps)
        [vs, grps] = tools.valsByGrp(D, fcn, opts);
    end
    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 18);
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    plot(grps, vs, 'k-', 'LineWidth', 4);
    for jj = 1:numel(grps)
        plot(grps(jj), vs(jj), '.', 'Color', clrs(jj,:), ...
            'MarkerSize', 50);
    end
    xlabel('\theta');
    ylabel('value');
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabelRotation', 45);

end
