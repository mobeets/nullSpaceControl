function Z = habContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 15, 'doSample', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    ths = B2.(opts.thetaNm);

    Zr = B2.latents*(RB2*RB2');
    Zsamp = nan(nt,nn);
    for t = 1:nt
        Zsamp(t,:) = pred.randZIfNearbyTheta(ths(t), B1, opts.thetaTol, ~opts.doSample);
%         Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end
    Zn = Zsamp*(NB2*NB2');
    Z = Zr + Zn;

end
