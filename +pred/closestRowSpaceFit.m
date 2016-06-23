function Z = closestRowSpaceFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    RB = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    
    ds = pdist2(Z2*RB, Z1*RB);
    [~, inds] = min(ds, [], 2);
    Z = Z1(inds,:);
    
    % prunung-inv
    ths = B1.thetas;
    nt2 = size(Z2,1);
    for t = 1:nt2
        thDs = getAngleDistance(ths, B2.thetas(t));
        Z1cur = Z1(thDs > 45,:);
        [~, ind] = min(pdist2(Z2(t,:)*RB, Z1cur*RB));
        Z(t,:) = Z1cur(ind,:);
    end

end

function ds = getAngleDistance(Z, z)
    dst = @(d1,d2) abs(mod((d1-d2 + 180), 360) - 180);
    ds = bsxfun(dst, Z, z);
end

