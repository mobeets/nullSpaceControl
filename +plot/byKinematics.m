function byKinematics(xs, ys, nm, clr, ylbl)
    if nargin < 3
        nm = '';
    end
    if nargin < 4
        clr = [0.7 0.7 0.7];
        doCmap = true;
    else
        doCmap = false;
    end
    if nargin < 5
        ylbl = 'norm of activity';
    end
    
%     [~,ix] = sort(xs); xs = xs(ix,:); ys = ys(ix,:);
    if doCmap
        cmap = cbrewer('div', 'RdYlGn', numel(xs));
        cmap = circshift(cmap, floor(numel(xs)/2));
    end
    
    sz = 50;
    hold on;
    
    set(gca, 'LineWidth', 3);
    set(gca, 'FontSize', 14);
    plot(xs, ys, 'Color', clr, 'LineWidth', 3);
    for ii = 1:numel(xs)
        if doCmap
            clrs = cmap(ii,:);
        else
            clrs = clr;
        end
        scatter(xs(ii), ys(ii), sz, clrs, ...
            'MarkerFaceColor', clrs, 'HandleVisibility', 'off');
    end    
    xlim([-25 385]);
%     ylim([0 max(1.2*nanmax(ys), 3.5)]);
    set(gca, 'XTick', xs(1:2:end));
    
    set(gcf, 'color', 'white');
    if ~isempty(nm)
        title(nm, 'FontSize', 14);
    end
    xlabel('\theta');    
    ylabel(ylbl);

end
