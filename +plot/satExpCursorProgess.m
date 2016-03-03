function [prms, ysa, xsa] = satExpCursorProgess(B, grpName, yThresh, xStart)
    if nargin < 2
        grpName = 'targetAngle';
    end
    if nargin < 3
        yThresh = 0.85;
    end

    [ysa, xsa] = tools.cursorProgressAvg(B, grpName);
    X = xsa - min(xsa);
    xmx = find(~isnan(X), 1, 'last');
    clrs = cbrewer('div', 'RdYlGn', size(ysa,2));
    if size(ysa,2) == 1
        ncols = 1; nrows = 1;
    else
        ncols = 2; nrows = 4;
    end

    set(gcf, 'color', 'w');
    prms = nan(size(ysa,2),4);
    for ii = 1:size(ysa,2)
        Y = ysa(:,ii);
        satexp = @(x) x(1) - (x(1)-x(2))*exp(-X/x(3));
        obj= @(x) nanmean((satexp(x) - Y).^2);
%         x0 = [nanmean(Y(end-20:end)) nanmean(Y(1:20)) numel(Y)/2];
        x0 = [nanmin(Y) nanmax(Y) numel(Y)/2];
        xm = fmincon(obj, x0);

        subplot(nrows,ncols,ii); hold on;
        set(gca, 'FontSize', 14);
        plot(X, Y, 'k.');
        plot(X, satexp(xm), '-', 'Color', clrs(ii,:), 'LineWidth', 3);

        if xm(1) < xm(2)
            xth = nan;
        else
            xth = find(satexp(xm) > xm(1)*yThresh, 1, 'first');
        end
        if ~isempty(xth)
            plot([xth xth], ylim, 'k--');
        else
            xth = nan;
        end        
        prms(ii,:) = [xm xth];
        xlim([0 max(X)+1]);
        ylim([min(ysa(:)) max(ysa(:))]);
        if nargin > 3
            plot([xStart xStart], ylim, 'r--');
        end
    end    
    xlabel('trials');
    ylabel('cursor progress');

end
