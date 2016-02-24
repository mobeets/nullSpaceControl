function [ms, ses, covs, allgrps] = calcGroupMeanAndSE(xs, ys, allgrps)
    
    ngrps = numel(allgrps);
    nys = size(ys,2);
    ms = nan(ngrps,nys);
    ses = nan(ngrps,nys);
    covs = cell(ngrps,1);
    
    for ii = 1:ngrps
        ix = (xs == allgrps(ii));
        ysc = ys(ix,:);
        ms(ii,:) = mean(ysc);
        ses(ii,:) = std(ysc);
        covs{ii} = cov(ysc);
    end
end
