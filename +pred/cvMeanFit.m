function Z = cvMeanFit(D, opts)
% using the training set, take the mean latent activity
%   for each kinematics condition
% 
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'doNull', true, ...
        'doCheat', true, 'thetaNm', 'thetaActuals', 'grpNm', 'thetaActualGrps');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if ~opts.doCheat
        Z = repmat(bestMeanObj(D), size(D.blocks(2).latents, 1), 1);
        return;
    end
    
    Blk = D.blocks(2);
    ix0 = Blk.idxTrain;
    ix1 = Blk.idxTest;
    NB = Blk.(opts.decoderNm).NulM2;
    
    % mean for each kinematics condition
    ths = Blk.(opts.thetaNm); ths = ths(ix0,:);
    cnts = sort(unique(Blk.(opts.grpNm)));
    ys = Blk.latents(ix0,:);
    if opts.doNull
        ys = ys*NB;
    end
    [mus, ses, covs] = score.avgByThetaGroup(ths, ys, cnts);
    
    % find kinematics condition for each point in test data
    grps = score.thetaGroup(Blk.(opts.thetaNm), cnts);
%     grps = grps(ix0);
    
    if opts.doNull
        Z = nan(size(Blk.latents,1), size(NB,2));
    else
        Z = nan(size(Blk.latents));
    end
    
    for ii = 1:numel(cnts)
        ix = cnts(ii) == grps;
        if sum(ix) == 0
            continue;
        end
        Z(ix & ix1,:) = mvnrnd(mus(ii,:), covs{ii}, sum(ix & ix1));
    end
    if opts.doNull
        Z = Z*NB';
    end
    
end

function sol = bestMeanObj(D)
    % search for best mean rate to predict

    B1 = D.blocks(1);
    NB = B1.fDecoder.NulM2;
    
    zMu = pred.avgByThetaGroup(B1, B1.latents*NB);
    nd = size(B1.latents,1);
    obj = @(mu) score.errOfMeans(zMu, ...
        pred.avgByThetaGroup(B1, repmat(mu, nd, 1)*NB));
    mu0 = mean(B1.latents);
    sol = fminunc(obj, mu0);
    
end
