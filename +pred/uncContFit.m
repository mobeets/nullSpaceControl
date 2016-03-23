function Z = uncContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);

    % sample Z uniformly from B1 for each time point
    ntB1 = size(D.blocks(1).latents,1);
    Zsamps = D.blocks(1).latents(randi(ntB1, nt, 1),:);    
    Zn = Zsamps*(NB2*NB2');
    
    % n.b. we could actually just stop here, since we have our Zn
    Zr = nan(nt,nn);
    for t = 1:nt
        Zr(t,:) = pred.rowSpaceFit(B2, B2.(opts.decoderNm), NB2, RB2, t);
    end
    Z = Zr + Zn;
end
