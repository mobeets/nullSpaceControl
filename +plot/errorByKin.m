function errorByKin(Hs, ynm, clrs, errBarNm)
    if nargin < 3 || isempty(clrs)
        clrs = [get(gca,'ColorOrder'); parula(64)];
%         clrs = cbrewer('qual', 'Set2', numel(Hs));
    end
    if nargin < 4
        errBarNm = '';
    end
    
    ths = Hs(1).grps;
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 24);
    
    fldnm = [ynm '_boots'];
    if ~isfield(Hs(1), fldnm)
        fldnm = ynm;
    end
    vb = {Hs.(fldnm)};
    if strcmpi(errBarNm, 'se')
       [valsA, errL, errR] = plot.getSeErrorBars(vb);
    else
        valsA = [];
    end
    
    for ii = 1:numel(Hs)
        clr = clrs(ii,:);
        
        if isempty(valsA)
            vals = Hs(ii).(ynm);
        else
            vals = valsA(ii,:);
        end        
        if isempty(vals)
            vals = nan(size(ths));
        end
        
        plot(ths, vals, '-o', ...
            'Color', clr, 'MarkerFaceColor', clr, ...
            'MarkerEdgeColor', clr, 'LineWidth', 3);
        if ~isempty(valsA)
            line([ths ths]', [errL(ii,:); errR(ii,:)], 'Color', clr, ...
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
