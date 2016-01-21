function Z = dummyFit(D)

%     mu = mean(D.blocks(1).latents);
    mu = bestMeanObj(D);
%     mu = 0*ones(size(mu));
    Z = repmat(mu, size(D.blocks(2).latents, 1), 1);
    
    
%     % response is always orthogonal to null space
%     B2 = D.blocks(2);
%     NB2 = null(B2.fDecoder.M2);
%     [nt, nn] = size(B2.latents);
%     Z = nan(nt,nn);
%     for t = 1:nt
%         Z(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, t);
%     end
   

end

function sol = bestMeanObj(D)
    % search for best mean rate to predict

    B1 = D.blocks(1);
    NB = null(B1.fDecoder.M2);
    zMu = pred.nullActivityByTrgAng(B1, B1.latents', NB);    
    nd = size(B1.latents,1);
    obj = @(mu) score.errOfMeans(zMu, ...
        pred.nullActivityByTrgAng(B1, repmat(mu, nd, 1)', NB));
    mu0 = mean(B1.latents);
    sol = fminunc(obj, mu0);
    
%     disp([mu0; sol; mu0 - sol]);
end

function permuteActuals(D)
    B1 = D.blocks(1);
    NB = null(B1.fDecoder.M2);    
    zMu = pred.nullActivityByTrgAng(B1, B1.latents', NB);
    % zMu is the actual mean null activity for each kinematics condition
    % now, for each kinematics condition in B1, find the closest 
    % kinematics condition (in terms of associated latent states)
    % and simply predict that one.
    % so it's like a shuffling of zMu's kinematics
    
end
