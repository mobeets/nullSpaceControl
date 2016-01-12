function Z = volContFit(D)

    Zpre = nan(nt,1);
    Zvol = nan(nt,1);
    % need to set x(0) to set Z(1)
    for t = 2:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        Zsamp = pred.randZIfNearbyTheta(D.blocks(2).theta(t), D.blocks(1));
        Zpre(t) = [];
        Zvol(t) = pred.rowSpaceFit(x(t), x(t-1), A2, B2, ...
            B2*ZPre(t) + c2, NB1);
    end
    Z = Zvol + Zpre;
    
end
