function Z = habContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 15, 'doSample', true, 'obeyBounds', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    ths = B2.(opts.thetaNm);

    Zr = B2.latents*(RB2*RB2');
    Zsamp = nan(nt,nn);
    
    mns = min(B1.latents);
    mxs = max(B1.latents);
    isOutOfBounds = @(z, mns, mxs) all(isnan(z)) || ...
        (sum(z < mns) > 0 || sum(z > mxs) > 0);
    d = 0;
    for t = 1:nt
        c = 0;
        while isOutOfBounds(Zsamp(t,:)*(NB2*NB2') + Zr(t,:), mns, mxs) && c < 10
            Zsamp(t,:) = pred.randZIfNearbyTheta(ths(t), B1, opts.thetaTol, ~opts.doSample);
            if opts.obeyBounds
                c = c+1;
            else
                c = 10;
            end
        end
        if c > 1 && c < 10
            d = d + 1;
        end
%         Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end
    warning(['Corrected ' num2str(d) ' habitual samples to lie within bounds']);
    Zn = Zsamp*(NB2*NB2');
    Z = Zr + Zn;

end
