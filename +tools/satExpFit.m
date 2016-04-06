function [prms, xths] = satExpFit(xsa, ysa, yThresh, subtractMin)
% returns:
%   prms = [yEnd yStart tau]
%   xs0 = x where y crosses yThresh
%

    if nargin < 3 || isnan(yThresh)
        yThresh = 0.85;
    end
    if nargin < 4
        subtractMin = true;
    end

    if subtractMin
        X = xsa - min(xsa);
    else
        X = xsa;
    end
    opts = optimoptions('fmincon', 'Display', 'off');

    prms = nan(size(ysa,2),3);
    xths = nan(size(ysa,2),1);
    for ii = 1:size(ysa,2)
        Y = ysa(:,ii);
        if sum(~isnan(Y)) == 0
            continue;
        end
        obj = @(th) nanmean((tools.satExp(X, th) - Y).^2);
        th0 = [nanmin(Y) nanmax(Y) numel(Y)/2];
        th = fmincon(obj, th0, [],[],[],[],[],[],[], opts);

        xth = satExpInv((th(1)-th(2))*yThresh + th(2), th);
        prms(ii,:) = th;
        xths(ii) = xth;
    end

end

function x = satExpInv(y, th)
    x = -th(3)*log((th(1) - y)/(th(1)-th(2)));
end
