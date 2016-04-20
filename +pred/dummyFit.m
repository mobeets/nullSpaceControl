function Z = dummyFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    % response is always orthogonal to null space
    B2 = D.blocks(2);
    RB2 = B2.(opts.decoderNm).RowM2;
    Z = B2.latents*(RB2*RB2');

end
