function [ce, nums, dens] = tmp(predictions, theta, nullBasis)
    [~, ~, ~, ~, realBinnedLatents] = getMeanAndSE(predictions(1).latents,theta,nullBasis);
    [~, ~, ~, ~, hypBinnedLatents] = getMeanAndSE(predictions(2).latents,theta,nullBasis);
    [ce, nums, dens] = computeCovError(realBinnedLatents, hypBinnedLatents);
end

function [covError, nums, dens] = computeCovError(realBinnedLatents, hypBinnedLatents)
    
    nc = size(realBinnedLatents,2);
    dim = size(realBinnedLatents{1,1},1);
    assert(dim == 8);
    nums = cell(nc,1);
    dens = cell(nc,1);

    covError = 0;
    for c = 1:nc
    %     covError = covError + (1/numCond)*det(cov(binnedLatents{2,c}'));
        num = cov(hypBinnedLatents{2,c}');
        den = cov(realBinnedLatents{2,c}');
        
        s = svd(num);
%         s = diag(s);
        s2 = s(s > 1e-10);
        num2 = prod(s2);
        
%         [det(num) num2 prod(s)^(1/8) prod(s.^(1/8))]

        snum = svd(num);
        sden = svd(den);
%         covError = covError + (1/nc)*prod(snum.^(1/dim))/prod(sden.^(1/dim));
        
%         covError = covError + (1/nc)*(num2/det(den))^(1/dim);
        
        covError = covError + (1/nc)*(det(num)/det(den))^(1/dim);
        nums{c} = num;
        dens{c} = den;
    end
end
