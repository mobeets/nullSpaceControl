function Z = closestNulValFit_cheat(D, opts)
% choose intuitive pt closest to nul val
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB = B2.(opts.decoderNm).NulM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    ds = pdist2(Z2*NB, Z1*NB);
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);

end
