function Z = closestRowValFit(D, opts)
% aka cloud
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'kNN', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    ds = pdist2(Z2*RB2, Z1*RB2);
    if isnan(opts.kNN)
        [~, inds] = min(ds, [], 2);
    else
        % sample inds from kNN nearest neighbors
        inds = sampleFromCloseInds(ds, opts.kNN);
    end
    Zsamp = Z1(inds,:);
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');

end

function inds = sampleFromCloseInds(ds, k)
    [~,ix] = sort(ds, 2);
    ix = ix(:,1:k);
    sampInd = randi(k, size(ds,1), 1);
    ixSamp = sub2ind(size(ds), 1:size(ds,1), sampInd');
    inds = ix(ixSamp)';
end
