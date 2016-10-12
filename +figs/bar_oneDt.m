function bar_oneDt(S, nms, clrs, ylbl, bs, ymx)
    if nargin < 5
        bs = [];
    end
    if nargin < 6
        ymx = nan;
    end

    for ii = 1:numel(nms)
        bar(ii, S(ii), 'FaceColor', clrs(ii,:));
    end
    if ~isempty(bs)
        for ii = 1:numel(nms)
            plot([ii ii], bs(:,ii), 'k-');
        end
    end

    set(gca, 'XTick', 1:numel(nms));
    set(gca, 'XTickLabel', nms);
    set(gca, 'XTickLabelRotation', 45);
    ylabel(ylbl);
    if ~isnan(ymx)
        ylim([0 ymx]);
        set(gca, 'YTick', 1:ymx);
    end

end
