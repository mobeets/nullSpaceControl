function Z = uncContFit(D)

    B2 = D.blocks(2);
    NB2 = null(B2.fDecoder.M2);
    [nt, nn] = size(B2.latents);

    % sample Z uniformly from B1 for each time point
    ntB1 = size(D.blocks(1).latents,1);
    Zsamps = D.blocks(1).latents(randi(ntB1, nt, 1),:);    
    Zn = ((NB2*NB2')*Zsamps')';
    
    Zr = nan(nt,nn);
    for t = 1:nt
        Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, t);
    end
    Z = Zr + Zn;
end
