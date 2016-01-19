function Z = dummyFit(D)

    mu = mean(D.blocks(1).latents);
%     mu = 4*ones(size(mu));
    Z = repmat(mu, size(D.blocks(2).latents, 1), 1);
    
end
