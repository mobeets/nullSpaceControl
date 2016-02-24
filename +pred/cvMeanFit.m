function Z = cvMeanFit(D, doNull)
% using the training set, take the mean latent activity
%   for each kinematics condition
% 

    Blk = D.blocks(2);
    ix0 = Blk.idxTrain;
    ix1 = Blk.idxTest;
    NB = Blk.fDecoder.NulM2;
    
    % mean for each kinematics condition
    ths = Blk.thetas(ix0,:) + 180;
    cnts = score.thetaCenters(8);
    ys = Blk.latents(ix0,:);
    if doNull
        ys = ys*NB;
    end
    [mus, ses, covs] = score.avgByThetaGroup(ths, ys, cnts);
    
    % find kinematics condition for each point in test data
%     xs = Blk.thetas(ix1,:) + 180;
%     grps = score.thetaGroup(xs, cnts);
    grps = score.thetaGroup(Blk.thetas + 180, cnts);
    
    if doNull
        Z = nan(size(Blk.latents,1), size(NB,2));
    else
        Z = nan(size(Blk.latents));
    end
    
    for ii = 1:numel(cnts)
        ix = cnts(ii) == grps;
        Z(ix & ix1,:) = mvnrnd(mus(ii,:), covs{ii}, sum(ix & ix1));
    end
    if doNull
        Z = Z*NB';
    end
    
end
