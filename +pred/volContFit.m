function Z = volContFit(D, addPrecursor)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB1 = B1.fDecoder.NulM2;
    RB1 = B1.fDecoder.RowM2;
    [nt, nn] = size(B2.latents);

    Zpre = zeros(nt,nn);
    Zvol = nan(nt,nn);
    % need to set x(0) to set Z(1)
    for t = 1:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        decoder = B2.fDecoder;
        if addPrecursor
            Zpre(t,:) = pred.randZIfNearbyTheta(B2.thetas(t) + 180, B1, ...
                nan, false);
            decoder.M0 = decoder.M0 + decoder.M2*Zpre(t,:)';
        end
        Zvol(t,:) = pred.rowSpaceFit(B2, decoder, NB1, RB1, t);
    end
    Z = Zvol + Zpre;
    
end
