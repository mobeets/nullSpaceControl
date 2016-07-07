function singleValByGrp(vs, grps, D, fcn, opts)
    if nargin > 2 && isempty(vs) && isempty(grps)
        [vs, grps] = tools.valsByGrp(D, fcn, opts);
    end
    if nargin < 5
        opts = struct();
    end
    if ~isfield(opts, 'LineMarkerStyle')
        opts.LineMarkerStyle = 'k-';
    end
    if isfield(opts, 'noColors') && opts.noColors
        clrs = ones(numel(grps),3);
        mrkSz = 1;
    else
        clrs = cbrewer('div', 'RdYlGn', numel(grps));
        mrkSz = 50;
    end
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 18);
    plot(grps, vs, opts.LineMarkerStyle, 'LineWidth', 4);
    for jj = 1:numel(grps)
        plot(grps(jj), vs(jj), '.', 'Color', clrs(jj,:), ...
            'MarkerSize', mrkSz, 'HandleVisibility', 'off');
    end
    xlabel('\theta');
    ylabel('value');
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabelRotation', 45);

end
