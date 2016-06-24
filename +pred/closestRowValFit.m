function Z = closestRowValFit(D, opts)
% aka cloud
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    RB = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    ds = pdist2(Z2*RB, Z1*RB);
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);

end
