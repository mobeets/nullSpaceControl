function Z = uncContFit(D)

    % sample Z uniformly from B1 for each time point
    ntB1 = size(D.blocks(1).latents,1);
    Zsamps = D.blocks(1).latents(randi(ntB1, nt, 1),:);
    
    B2 = D.blocks(2);
    NB2 = null(B2.fDecoder.M2);
    
    Zr = nan(nt,1);
    Zn = nan(nt,1);
    for t = 1:nt
        Zr(t) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, t);
        Zn(t) = NB2*NB2'*Zsamps(t);
    end

    Z = Zr + Zn;
end
