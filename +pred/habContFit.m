function Z = habContFit(D)
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    [nt, nn] = size(B2.latents);
    
    Zr = nan(nt,nn);
    Zn = nan(nt,nn);
    for t = 1:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        Zsamp = pred.randZIfNearbyTheta(B2.thetas(t) + 180, B1);
%         Z(t,:) = Zsamp;
        Zn(t,:) = Zsamp*(NB2*NB2');
        Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end
        
    Z = Zr + Zn;

end
