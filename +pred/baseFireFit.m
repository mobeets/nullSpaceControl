function Z = baseFireFit(D)

    B2 = D.blocks(2);
    Dc = D.simpleData.nullDecoder;
    mu = Dc.spikeCountMean;
    
    [nt, nu] = size(B2.spikes);
    U = nan(nt,nu);
    for t = 1:nt
        U(t,:) = pred.quadFireFit(B2, t, -mu, B2.nDecoder, false);
    end
    Z = tools.convertRawSpikesToRawLatents(Dc, U');
end
