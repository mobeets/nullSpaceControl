function Z = baseFireFit(D)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    f = mu;
    
    Z = nan(nt,1);
    for t = 1:nt
        Z(t) = pred.quadFireFit(B1, f, B2.nDecoder, false);
    end

end
