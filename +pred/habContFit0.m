function Z = habContFit(D, useActualTheta)
    if nargin < 2
        useActualTheta = false;
    end
    if useActualTheta
        thNm = 'thetaActuals';
    else
        thNm = 'thetas';
    end
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
%     NR1 = B1.fDecoder.RowM2;
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    [nt, nn] = size(B2.latents);

%     Zr = nan(nt,nn);
    Zr = B2.latents*(RB2*RB2');
    Zsamp = nan(nt,nn);
    for t = 1:nt
        Zsamp(t,:) = pred.randZIfNearbyTheta(B2.(thNm)(t), B1);
%         Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end
    
    Zn = Zsamp*(NB2*NB2'); % = Zsamp*(NR1*NR1')*(NB2*NB2');
    Z = Zr + Zn;

end
