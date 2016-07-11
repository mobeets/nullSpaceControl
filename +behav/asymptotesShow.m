function asymptotesOverall(thsByGrp, ths, nms, grps)

    clrs = cbrewer('qual', 'Set1', numel(nms));
    
    % plot bars
    wdth = 0.8;
    for jj = 1:numel(nms)
        bar(grps, thsByGrp(:,jj), wdth, ...
            'EdgeColor', clrs(jj,:), 'FaceColor', clrs(jj,:));
        wdth = wdth - 0.1;
    end    
    
    % plot global asymptote
    for jj = 1:numel(nms)
        if ~isnan(ths(jj))
            plot(xlim, [ths(jj) ths(jj)], '--', 'Color', clrs(jj,:), ...
                'LineWidth', 3);
        end
    end
    
    legend(nms, 'Location', 'BestOutside');    
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
    set(gca, 'XTickLabelRotation', 45);
    xlabel('\theta');
    ylabel('behavioral asymptote (trial #)');

end
