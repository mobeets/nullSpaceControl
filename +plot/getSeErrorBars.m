function [mus, errL, errR] = getSeErrorBars(ysb)

    errL = nan(numel(ysb), max(cellfun(@(x) size(x,2), ysb)));
    errR = nan(size(errL));
    mus = nan(size(errL));
    for ii = 1:numel(ysb)
        ysc = ysb{ii};
        es = prctile(ysc, [25 75], 1);
        if isempty(es)
            continue;
        end
        errL(ii,:) = es(1,:);
        errR(ii,:) = es(2,:);
        mus(ii,:) = mean(ysc,1);
    end
    
    if size(mus,2) == 1
        mus = mus';
        errL = errL';
        errR = errR';
    end

end
