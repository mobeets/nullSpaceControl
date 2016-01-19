function Z = minFireFit(D)

    B2 = D.blocks(2);
    Dc = D.simpleData.nullDecoder;
    
    [nt, nu] = size(B2.spikes);
    U = nan(nt,nu);
    for t = 1:nt
        U(t,:) = pred.quadFireFit(B2, t, [], B2.nDecoder, false);
    end
    Z = io.convertRawSpikesToRawLatents(Dc, U')';

end
