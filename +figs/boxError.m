function boxError(pts, nms, clrs, ylbl, ymx)
    if nargin < 3
        clrs = ones(size(pts,1),3);
    end
    if nargin < 4
        ylbl = 'error';
    end
    if nargin < 5
        ymx = nan;
    end
    lw = 2;
    msz = 15;
    
    bp = boxplot(pts, 'Colors', clrs, 'Symbol', '.', ...
        'OutlierSize', 12);
    set(bp, 'LineWidth', lw);
    set(findobj(gcf,'LineStyle','--'),'LineStyle','-');
    
%     ms = mean(pts);
%     bs = 2*std(pts)/sqrt(size(pts,1));
%     for ii = 1:size(pts,2)
%         plot([ii ii], [ms(ii)-bs(ii) ms(ii)+bs(ii)], '-', ...
%             'Color', 'k', 'LineWidth', lw);
% %         plot(ii, ms(ii), 'o', 'MarkerFaceColor', clrs(ii,:), ...
% %             'MarkerEdgeColor', 'k', 'MarkerSize', msz, ...
% %             'LineWidth', lw);
%         plot([ii-0.5 ii+0.5], [ms(ii) ms(ii)], '-', ...
%             'Color', clrs(ii,:), 'LineWidth', 2*lw);
%     end
    set(gca, 'XTick', 1:numel(nms));
    set(gca, 'XTickLabel', nms);
    set(gca, 'TickDir', 'out');
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', lw);
    xlim([0.25 numel(nms)+0.75]);
    ylabel(ylbl);
    if ~isnan(ymx)
        ylim([0 ymx]);
        set(gca, 'YTick', 0:ymx);
    else
        yl = ylim;
        ylim([0 yl(2)]);
    end
    if max(cellfun(@numel, nms)) > 3 % if longest name > 3 chars
        set(gca, 'XTickLabelRotation', 45);
    end
    
%     nms = nms(end:-1:1);
%     pts = pts(:,end:-1:1);
%     clrs = clrs(end:-1:1,:);    
%     bp = boxplot(pts, 'Colors', clrs, 'Symbol', '.', ...
%         'OutlierSize', 12, 'Orientation', 'Horizontal');
%     set(bp, 'LineWidth', lw);
%     
%     set(gca, 'YTick', 1:numel(nms));
%     set(gca, 'YTickLabel', nms);
%     set(gca, 'TickDir', 'out');
%     set(gca, 'Ticklength', [0 0]);
%     set(gca, 'LineWidth', lw);
%     ylim([0.25 numel(nms)+0.75]);
%     xlabel(ylbl);
%     if ~isnan(ymx)
%         xlim([0 ymx]);
%         set(gca, 'XTick', 1:ymx);
%     end
    box off;

end
