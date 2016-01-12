function Z = uncContFit(D)

    Zr = nan(nt,1);
    % need to set x(0) to set Zr(1)
    for t = 2:nt        
        Zr(t) = pred.rowSpaceFit(x(t), x(t-1), A2, B2, c2, NB2);
    end
    
    % sample Z uniformly from T1
    Zsamp = [];
    
    Zn = NB2*NB2'*Zsamp;
    Z = Zr + Zn;

end
