function quickBehavior(D, behavNm, grpName, fldNms, flipSign)
    if nargin < 3
        grpName = '';
    end
    if nargin < 4
        fldNms = {};
    end
    if nargin < 5
        flipSign = false;
    end
    if isa(fldNms, 'char')
        fldNms = {fldNms};
    end
    [prms, grps, nms] = tools.quickBehavior(D, behavNm, grpName, flipSign);
    prms(abs(prms) > 1e3) = nan;
    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 18);

    plot(grps, zeros(size(grps)), ':', 'Color', [0.8 0.8 0.8], ...
        'LineWidth', 4, 'HandleVisibility', 'off');
    if numel(fldNms) ~= 1
        inds = 1:size(prms,2);
        if ~isempty(fldNms)
            fldInds = ismember(nms, fldNms);
            inds = inds(fldInds);
        end
        nflds = numel(inds);
        for ii = 1:nflds
            vs = prms(:,inds(ii));
            vs = vs./max(abs(vs));
            plot(grps, vs, '.-', 'MarkerSize', 30, 'LineWidth', 4);
        end
        legend(nms{inds}, 'Location', 'Best');
        legend boxoff;
        ylabel(behavNm);
    else
        fldInd = strcmp(fldNms, nms);
        plot(grps, prms(:,fldInd), 'k-', 'LineWidth', 4);
        clrs = cbrewer('div', 'RdYlGn', numel(grps));
        for ii = 1:numel(grps)
            plot(grps(ii), prms(ii,fldInd), '.', 'Color', clrs(ii,:), ...
                'MarkerSize', 50);
        end
        ylabel(nms{fldInd});
    end
    
    xlabel('\theta');
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabelRotation', 45);
end
