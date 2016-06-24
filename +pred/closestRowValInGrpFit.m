function Z = closestRowValInGrpFit(D, opts)
% aka pruning
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 30);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    RB = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    ths1 = B1.(opts.thetaNm);
    ths2 = B2.(opts.thetaNm);
    
    ds = pdist2(Z2*RB, Z1*RB);
    dsThs = pdist2(ths2, ths1);
    ds(dsThs > opts.thetaTol) = inf;
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);

end
