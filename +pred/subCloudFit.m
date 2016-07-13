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
    RB1 = B1.(opts.decoderNm).RowM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    inds = 1:8;
    Zps = cell(numel(inds),1);
    for ii = 1:numel(inds)
        ind = inds(ii);
        Nc = NB1(:,ind);
        Bs = Nc*Nc';
        Zps{ii} = subCloud(Z1*Bs, Z2*Bs, RB2);
%         Zps{ii} = subCloud(Z1*Bs*RB2, Z2*Bs*RB2, Z1*Bs)*Nc;
    end
%     Zc = cat(2, Zps{:});
%     Zc = Zc*NB1';
    Zc = sum(cat(3, Zps{:}),3);
    Bs = RB1*RB1';
    Zc = Zc + subCloud(Z1*Bs, Z2*Bs, RB2);
end

function Z = subCloud(Z1, Z2, RB)
    ds = pdist2(Z2*RB, Z1*RB);
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);
end

