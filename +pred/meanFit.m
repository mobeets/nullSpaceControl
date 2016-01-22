function Z = meanFit(D, opt)

    if strcmpi(opt, 'zero')
        mu = zeros(1,size(D.blocks(1).latents,2));
    elseif strcmpi(opt, 'mean')
        mu = mean(D.blocks(1).latents);
    else
        mu = bestMeanObj(D);
    end
    nt = size(D.blocks(2).latents, 1);
    Z = repmat(mu, nt, 1);
end

function sol = bestMeanObj(D)
    % search for best mean rate to predict

    B1 = D.blocks(1);
    NB = null(B1.fDecoder.M2);
    
    zMu = pred.avgByThetaGroup(B1, B1.latents*NB);
    nd = size(B1.latents,1);
    obj = @(mu) score.errOfMeans(zMu, ...
        pred.avgByThetaGroup(B1, repmat(mu, nd, 1)*NB));
    mu0 = mean(B1.latents);
    sol = fminunc(obj, mu0);
    
end
