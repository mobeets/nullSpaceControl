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
    mus = score.avgByThetaGroup(ths, ys, cnts);
    
    % find kinematics condition for each point in test data
    xs = Blk.thetas(ix1,:) + 180;
    grps = score.thetaGroup(xs, cnts);
    
    if doNull
        Z = nan(size(Blk.latents,1), size(NB,2));
    else
        Z = nan(size(Blk.latents));
    end
    
    inds = 1:numel(ix1); inds = inds(ix1);
    for ii = 1:numel(grps)
        Z(inds(ii),:) = mus(cnts == grps(ii),:);
    end
    if doNull
        Z = Z*NB';
    end
    
end
