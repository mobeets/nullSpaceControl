function errorByKin(Hs, ynm, clrs)
    if nargin < 3
        clrs = cbrewer('qual', 'Set2', numel(Hs));
    end
    
    ths = score.thetaCenters;    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 24);
    
    for ii = 1:numel(Hs)
        clr = clrs(ii,:);
        errs = Hs(ii).(ynm);
        if isempty(errs)
            errs = nan(size(ths));
        end
        
        plot(ths, errs, '-o', ...
            'Color', clr, 'MarkerFaceColor', clr, ...
            'MarkerEdgeColor', clr, 'LineWidth', 5);
    end
    set(gca, 'XTick', ths);
    set(gca, 'XTickLabelRotation', 45);
    xlabel('\theta');
    ylabel(ynm);
    legend({Hs.name}, 'Location', 'Best');
    legend boxoff;

end
