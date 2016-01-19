function Z = habContFit(D)
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = null(B2.fDecoder.M2);
    [nt, nn] = size(B2.latents);
    
    Zr = nan(nt,nn);
    Zn = nan(nt,nn);
    for t = 1:nt
        Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, t);
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        Zsamp = pred.randZIfNearbyTheta(B2.thetas(t), B1);
        Zn(t,:) = NB2*NB2'*Zsamp';
    end
        
    Z = Zr + Zn;

end
