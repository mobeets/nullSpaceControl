function [ms, ses, allgrps] = calcGroupMeanAndSE(xs, ys, allgrps)
    
    ngrps = numel(allgrps);
    nys = size(ys,2);
    ms = nan(ngrps,nys);
    ses = nan(ngrps,nys);
    
    for ii = 1:ngrps
        ix = (xs == allgrps(ii));
        ysc = ys(ix,:);
        ms(ii,:) = mean(ysc);
        ses(ii,:) = 2*std(ysc)/sqrt(size(ysc,1));
    end
end
