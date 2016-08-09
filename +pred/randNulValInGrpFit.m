function Z = randNulValInGrpFit(D, opts)
% choose intuitive pt within thetaTol
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 20);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB = B2.(opts.decoderNm).NulM2;
    RB = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;
    ths1 = B1.(opts.thetaNm);
    ths2 = B2.(opts.thetaNm);
    
    dsThs = pdist2(ths2, ths1, @tools.angleDistance);
    ix = dsThs <= opts.thetaTol;
    nix = sum(ix,2);
    nums = 1:size(ix,1);
    inds = arrayfun(@(t) nums(ix(t,:)), 1:size(Z2,1), 'uni', 0);
    Zsamp = cell2mat(arrayfun(@(t) Z1(inds{t}(randi(nix(t))),:), ...
        1:size(Z2,1), 'uni', 0)');
    Z = Z2*(RB*RB') + Zsamp*(NB*NB');

end
