function errorByKin(Hs, ynm, clrs)
    if nargin < 3 || isempty(clrs)
        clrs = [get(gca,'ColorOrder'); parula(64)];
%         clrs = cbrewer('qual', 'Set2', numel(Hs));
    end    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 24);
    
    ths = Hs(1).grps;
    for ii = 1:numel(Hs)
        clr = clrs(ii,:);
        vals = Hs(ii).(ynm);
        if isfield(Hs(ii), [ynm '_se'])
            errs = Hs(ii).([ynm '_se']);
        else
            errs = [];
        end
        plot(ths, vals, '-o', ...
            'Color', clr, 'MarkerFaceColor', clr, ...
            'MarkerEdgeColor', clr, 'LineWidth', 3);
        if ~isempty(errs)
            errL = vals - errs;
            errR = vals + errs;
            if size(errL,1) ~= 1
                errL = errL'; errR = errR';
            end
            line([ths ths]', [errL; errR], 'Color', clr, ...
                'LineWidth', 3, 'HandleVisibility', 'off');
%             errorbar(ths, vals, vals - errL(ii,:), errR(ii,:) - vals, ...
%                 'LineWidth', 5, 'Color', clr, 'LineStyle', '-');
        end
    end
    set(gca, 'XTick', ths);
    set(gca, 'XTickLabelRotation', 45);
    xlabel('\theta');
    ylabel(ynm);
    legend({Hs.name}, 'Location', 'Best');
    legend boxoff;

end
