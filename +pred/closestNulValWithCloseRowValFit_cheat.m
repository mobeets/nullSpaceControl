function Z = closestNulValWithCloseRowValFit_cheat(D, opts)
% choose intuitive pt within thetaTol and Row val, and closest to nul val
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'kNN', 50, 'nNN', 1);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB = B2.(opts.decoderNm).NulM2;
    RB = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    ds = pdist2(Z2*NB, Z1*NB);
    
    % ignore pts not within thetaTol
%     dsThs = pdist2(ths2, ths1);
%     ds(dsThs > opts.thetaTol) = inf;
    
    % ignore pts that aren't the 200 closest pts
    dsR = pdist2(Z2*RB, Z1*RB);
    dsRsrt = sort(dsR,2);
    dsRmx = dsRsrt(:,opts.kNN);
    ds(dsR > repmat(dsRmx, 1, size(ds,2))) = inf;
    
    if opts.nNN > 1 % take nNNth closest pt in nul space
        [~, dsIx] = sort(ds,2);
        inds = dsIx(:,opts.nNN);
        Z = Z1(inds,:);
    else % take closest pt in nul space
        [~, inds] = min(ds, [], 2);
        Z = Z1(inds,:);
    end

end
