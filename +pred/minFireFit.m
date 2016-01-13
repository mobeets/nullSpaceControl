function Z = minFireFit(D)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    
    Z = nan(nt,1);
    for t = 1:nt
        Z(t) = pred.quadFireFit(B1, [], B2.nDecoder, true);
    end

end
