function stickPlot(M1, M2, nm)
    if nargin < 4
        nm = '';
    end
    
    cnts = score.thetaCenters();

    cmap = cbrewer('div', 'RdYlGn', numel(cnts));
    xmx = 1.5*max([abs(cell2mat(M1)); abs(cell2mat(M2))]);
    for ii = 1:numel(M1{1})
        subplot(numel(M1{1}), 1, ii);
        hold on;
        set(gca, 'YDir', 'reverse');
        set(gca, 'Fontsize', 10);
        set(gca, 'Linewidth', 3);
        set(gca, 'XTick', [0]);
        set(gca, 'XTickLabel', {''});
        set(gca, 'YTick', [1 2]);
        set(gca, 'YTickLabel', {'Map 1', 'Map 2'});
        ylim([0.5 2.5]);
        xlim([-xmx xmx]);
        xlabel(['n_' num2str(ii) '^T\mu']);
        
        for jj = 1:numel(cnts)
            plot([M1{jj}(ii) M2{jj}(ii)], [1 2], 'Color', cmap(jj,:), ...
                'LineWidth', 3);
        end
    end
    set(gcf, 'color', 'white');
    if ~isempty(nm)
        plot.subtitle(nm, 'FontSize', 12);
    end
end
