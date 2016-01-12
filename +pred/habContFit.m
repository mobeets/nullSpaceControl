function Z = habContFit(D)
    
    Zr = nan(nt,1);
    Zn = nan(nt,1);
    % need to set x(0) to set Zr(1)
    for t = 2:nt        
        Zr(t) = pred.rowSpaceFit(x(t), x(t-1), A2, B2, c2, NB2);
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        Zsamp = pred.randZIfNearbyTheta(D.blocks(2).theta(t), D.blocks(1));
        Zn(t) = NB2*NB2'*Zsamp;
    end
        
    Z = Zr + Zn;

end
