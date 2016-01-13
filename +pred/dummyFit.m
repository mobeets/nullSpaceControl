function Z = dummyFit(D)

    mu = mean(D.blocks(1).latents);
    Z = repmat(mu, size(D.blocks(2).latents, 1), 1);
    
end
