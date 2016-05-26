function Z = uniFit(D, opts)
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    mn = min(Y1); mx = max(Y1);
    [nt, nc] = size(B2.latents);
    Z = bsxfun(@plus, mn, bsxfun(@times, mx-mn, rand(nt,nc)));
    
end
