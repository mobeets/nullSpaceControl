function Z = dummyFit(D)

    mu = mean(D.blocks(1).latents, 2);
    Z = repmat(mu, 1, size(D.blocks(2).latents, 2));
    
end
