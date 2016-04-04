function errorByKin(Hs, ynm)
    
    ths = score.thetaCenters;    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 14);

    clrs = cbrewer('qual', 'Set1', numel(Hs));
    for ii = 1:numel(Hs)
        clr = clrs(ii,:);
        errs = Hs(ii).(ynm);
        if isempty(errs)
            errs = nan(size(ths));
        end
        
        plot(ths, errs, '-o', ...
            'Color', clr, 'MarkerFaceColor', clr, ...
            'MarkerEdgeColor', clr, 'LineWidth', 3);
    end
    set(gca, 'XTick', ths);
    xlabel('\theta');
    ylabel(ynm);
    legend({Hs.name}, 'Location', 'BestOutside');

end