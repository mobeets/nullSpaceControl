function Z = habContFit(D)
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
%     NR1 = B1.fDecoder.RowM2;
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    [nt, nn] = size(B2.latents);
    
    Zr = nan(nt,nn);
    Zsamp = nan(nt,nn);
    for t = 1:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        Zsamp(t,:) = pred.randZIfNearbyTheta(B2.thetas(t) + 180, B1);
%         Zsamp(t,:) = pred.randZIfNearbyMinTheta(B2.thetas(t) + 180, B1, 10);
        Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end
    
    Zn = Zsamp*(NB2*NB2'); % = Zsamp*(NR1*NR1')*(NB2*NB2');
    Z = Zr + Zn;

end
