function z = pairwiseLags(Y, lags, fcn)
    if nargin < 3
        fcn = @(y) y;
    end
    nv = numel(fcn(Y(1,:)));

    z = nan(size(Y,1), numel(lags), nv);
    for ii = 1:size(Y,1)
        for jj = 1:numel(lags)
            if ii + lags(jj) > size(Y,1)
                continue;
            end
            y1 = Y(ii,:);
            y2 = Y(ii+lags(jj),:);
            z(ii,jj,:) = fcn(y2 - y1);
        end
    end

end
