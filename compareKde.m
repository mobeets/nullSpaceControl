function [P1, Ps, X, Y, b1, bs, scs] = compareKde(Z1, Zs, shareBw, scFcn)
    if nargin < 3
        shareBw = false;
    end
    if nargin < 4
        scFcn = @(p, ph) sum((p(:)-ph(:)).^2);
    end

    n = 2^8;
    [b1, P1, X, Y] = kde2d(Z1, n);
    
    xrng = [min(X(:)) max(X(:))]; yrng = [min(Y(:)) max(Y(:))];
    minxy = [xrng(1) yrng(1)]; maxxy = [xrng(2) yrng(2)];
    
    Ps = cell(numel(Zs),1);
    bs = cell(numel(Zs),1);
    scs = nan(numel(Zs),1);
    for ii = 1:numel(Zs)
        Z2 = Zs{ii};
        if shareBw        
            [b2, P2, X2, Y2] = kde2dv2(Z2, n, minxy, maxxy, b1);
            assert(isequal(b1, b2));
        else
            [b2, P2, X2, Y2] = kde2d(Z2, n, minxy, maxxy);
        end
        assert(isequal(X, X2)); assert(isequal(Y, Y2));
        Ps{ii} = P2;
        bs{ii} = b2;
        scs(ii) = scFcn(P1, P2);
    end
    
end
