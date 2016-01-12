function Z = minFireFit(D)

    nd = 86;
    f = zeros(nd,1);
    Z = nan(nt,1);
    % need to set x(0) to set Z(1)
    for t = 2:nt
        Z(t) = pred.quadFireFit(x(t), x(t-1), f, A2, B2, c2);
    end

end
