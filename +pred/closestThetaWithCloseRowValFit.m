function Z = closestThetaWithCloseRowValFit(D, opts)
% aka pruning-reverse
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'kNN', 50, ...
        'thetaNm', 'thetas', 'filterThetas', false, 'thetaTol', 30);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    RB = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    % Blk1 thetas under Blk2 mapping
%     YR1 = Z1*RB;
%     ths1 = arrayfun(@(t) tools.computeAngle(YR1(t,:), [1; 0]), ...
%         1:size(YR1,1))';
%     ths1 = mod(ths1, 360);
    ths1 = B1.(opts.thetaNm);
    ths2 = B2.(opts.thetaNm);
    
    ds = pdist2(ths2, ths1);    
    dsR = pdist2(Z2*RB, Z1*RB);
    
    if opts.filterThetas
        dsThs = ds;
        ds = dsR;
        ds(dsThs > opts.thetaTol) = inf;
    else % ignore pts that aren't the kNN closest pts
        dsRsrt = sort(dsR,2);
        dsRmx = dsRsrt(:,opts.kNN);
        ds(dsR > repmat(dsRmx, 1, size(ds,2))) = inf;
    end
    
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);

end
