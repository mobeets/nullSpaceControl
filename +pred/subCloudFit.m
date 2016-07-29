function Zc = subCloudFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Z1 = B1.latents;
    Z2 = B2.latents;
    NB1 = B1.(opts.decoderNm).NulM2;
    NB2 = B2.(opts.decoderNm).NulM2;
    RB1 = B1.(opts.decoderNm).RowM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    % this will f things up only if it cheats by using null space activity
    Z2 = Z2(randperm(size(Z2,1)),:)*(NB2*NB2') + Z2*(RB2*RB2');
    
    inds = 1:8;
    Zps = cell(numel(inds),1);
    for ii = 1:numel(inds)
        ind = inds(ii);
        Nc = NB1(:,ind);
        Bs = Nc*Nc';
        % THIS IS CHEATING! Z2*(Nc*Nc') will contain activity in NB2
        Zps{ii} = subCloud(Z1*Bs, Z2*Bs, RB2);
    end
    Zc = sum(cat(3, Zps{:}),3);
    Bs = RB1*RB1';
    Zc = Zc + subCloud(Z1*Bs, Z2*Bs, RB2);
end

function Z = subCloud(Z1, Z2, RB)
    ds = pdist2(Z2*RB, Z1*RB);
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);
end

