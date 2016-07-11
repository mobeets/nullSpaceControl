function [prms, xths, ysa, xsa] = satExpActivity(B, yNm, grpName, yThresh, xStart)
    if nargin < 2
        yNm = 'progress';
    end
    if nargin < 3
        grpName = 'targetAngle';
    end
    if nargin < 4 || isnan(yThresh)
        yThresh = 0.85;
    end
    if nargin < 5
        xStart = nan;
    end
    
    [ysa, xsa] = tools.avgPerTrial(B, yNm, grpName);
    [prms, xths] = tools.satExpFit(xsa, ysa, yThresh);
    X = xsa;
    clrs = cbrewer('div', 'RdYlGn', size(ysa,2));
    if size(ysa,2) == 1
        ncols = 1; nrows = 1;
    else
        ncols = 2; nrows = 4;
    end

    set(gcf, 'color', 'w');
    for ii = 1:size(ysa,2)
        subplot(nrows,ncols,ii); hold on;
        set(gca, 'FontSize', 14);
        
        Y = ysa(:,ii);
        th = prms(ii,:);
        xth = xths(ii);% + min(X);
        plot(X, Y, 'k.');
        plot(X, tools.satExp(X - min(X), th), '-', ...
            'Color', clrs(ii,:), 'LineWidth', 3);
        
        if ~isempty(xth)
            plot([xth xth], ylim, 'k--');
        end
        xlim([0 max(X)+1]);
        ylim([min(ysa(:)) max(ysa(:))]);
        if ~isnan(xStart)
            plot([xStart xStart], ylim, 'r--');
        end
    end    
    xlabel('trials');
    ylabel(yNm);

end

