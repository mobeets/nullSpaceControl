function Z = minFireFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'nDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if strcmp(opts.decoderNm(1), 'f')
        opts.decoderNm(1) = 'n';
        warning('baseFireFit must use spike decoder, not factors.');
    end

    B2 = D.blocks(2);
    Dc = D.simpleData.nullDecoder;
    
    [nt, nu] = size(B2.spikes);
    U = nan(nt,nu);
    for t = 1:nt
        U(t,:) = pred.quadFireFit(B2, t, [], B2.(opts.decoderNm), false);
    end
    Z = tools.convertRawSpikesToRawLatents(Dc, U');

end
