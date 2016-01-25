function Z = dummyFit(D)
    
    % response is always orthogonal to null space
    B2 = D.blocks(2);
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    [nt, nn] = size(B2.latents);
    Z = nan(nt,nn);
    for t = 1:nt
        Z(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end   

end

function permuteActuals(D)
    B1 = D.blocks(1);
    NB = B1.fDecoder.NulM2;
    zMu = pred.avgByThetaGroup(B1, B1.latents*NB);
    % zMu is the actual mean null activity for each kinematics condition
    % now, for each kinematics condition in B1, find the closest 
    % kinematics condition (in terms of associated latent states)
    % and simply predict that one.
    % so it's like a shuffling of zMu's kinematics
    
end
