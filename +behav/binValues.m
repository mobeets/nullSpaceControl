function [cs, cbs] = binValues(xs, bs, binSz)
% todo: restart for each new bs value

    allbs = sort(unique(bs));
    cs = [];
    cbs = [];
    for ii = 1:numel(allbs)
        xc = xs(bs == allbs(ii));
        cc = meanPerBin(xc, binSz);
        cs = [cs cc];
        cbs = [cbs allbs(ii)*ones(size(cc))];
    end
end

function cs = meanPerBin(xs, binSz)
% only keeps full bins

%     cs = smooth(xs, binSz)';
%     return;
    
    lbs = 1:binSz:numel(xs);
    cs = nan(size(lbs));
    for ii = 1:numel(lbs)
        lb = lbs(ii);
        ub = lb + binSz - 1;
        if ub > numel(xs)
            continue;
        end
        cs(ii) = nanmean(xs(lb:ub));
    end
    % remove empty bins
    if isnan(cs(end))
        cs = cs(1:end-1);
    end
end
