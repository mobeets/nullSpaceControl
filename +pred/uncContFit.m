function Z = uncContFit(D)

    % sample Z uniformly from B1 for each time point
    ntB1 = size(D.blocks(1).latents,2);
    Zsamps = D.blocks(1).latents(:,randi(ntB1, nt, 1));
    
    Zr = nan(nt,1);
    Zn = nan(nt,1);
    % need to set x(0) to set Zr(1)
    for t = 2:nt        
        Zr(t) = pred.rowSpaceFit(x(t), x(t-1), A2, B2, c2, NB2);
        Zn(t) = NB2*NB2'*Zsamps(t);
    end

    Z = Zr + Zn;
end
