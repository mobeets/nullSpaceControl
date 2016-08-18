function Z = closestRowValFit(D, opts)
% aka cloud
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'beDumb', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB1 = B1.(opts.decoderNm).NulM2;
    RB1 = B1.(opts.decoderNm).RowM2;
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    if opts.beDumb
        ds = pdist2(Z2*RB2, Z1*RB1);
    else
        ds = pdist2(Z2*RB2, Z1*RB2);
    end
    [~, inds] = min(ds, [], 2);
    Zsamp = Z1(inds,:);
    Zr = Z2*(RB2*RB2');
    if opts.beDumb
        Z = Zr + Zsamp*(NB1*NB2');
    else
        Z = Zr + Zsamp*(NB2*NB2');
    end

end
