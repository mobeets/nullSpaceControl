function Z = volContFit(D)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB1 = null(B1.fDecoder.M2);
    [nt, nn] = size(B2.latents);

    Zpre = nan(nt,nn);
    Zvol = nan(nt,nn);
    % need to set x(0) to set Z(1)
    for t = 1:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        Zpre(t,:) = pred.randZIfNearbyTheta(B2.thetas(t), B1);
        decoder = B2.fDecoder;
        decoder.M0 = decoder.M0 + decoder.M2*Zpre(t,:)';
        Zvol(t,:) = pred.rowSpaceFit(B2, decoder, NB1, t);
    end
    Z = Zvol + Zpre;
    
end
