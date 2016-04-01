function Z = condGaussFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    [nt, nn] = size(B2.latents);
    nNull = size(NB2,2);    
    
    % train
    YR = B1.latents*RB2;
    YN = B1.latents*NB2;
    mu = mean([YR YN]);
    S = cov([YR YN]);

    % predict, given YR2
    YR2 = B2.latents*RB2;
    ixUnknown = false(nn,1); ixUnknown(end-nNull+1:end) = true;
    [mubar,~] = tools.condGaussMean(mu, S, ixUnknown);
    
    Zsamp = nan(nt,nNull);
    for t = 1:nt
        Zsamp(t,:) = mubar(YR2(t,:));
    end
    Zn = Zsamp*NB2';
    Zr = B2.latents*(RB2*RB2');
    Z = Zr + Zn;
end
