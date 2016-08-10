function Z = randNulValInGrpFit(D, opts)
% choose intuitive pt within thetaTol
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 20, 'obeyBounds', false, 'boundsType', 'marginal');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;    
    ths1 = B1.(opts.thetaNm);
    ths2 = B2.(opts.thetaNm);
    
    dsThs = pdist2(ths2, ths1, @tools.angleDistance);
    ix = dsThs <= opts.thetaTol;
    [Zsamp, nErrs] = getSamples(Z1, ix);
    
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');
    
    if opts.obeyBounds
        % resample invalid points
        isOutOfBounds = pred.boundsFcn(Z1, opts.boundsType, D);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        maxC = 10;
        c = 0;        
        while sum(ixOob) > 0 && c < maxC
            [Zsamp, nErrs] = getSamples(Z1, ix(ixOob,:));
            Z(ixOob,:) = Zr(ixOob,:) + Zsamp*(NB2*NB2');
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            warning(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' habitual samples to lie within bounds']);
        end
    end
    if nErrs > 0
        warning([num2str(nErrs) ...
            ' habitual samples had no neighbors within range.']);
    end

end

function [Zsamp, nZero] = getSamples(Z1, ix)
    nt = size(ix,1);
    nix = sum(ix,2);
    
    % if nothing is in range, sample from anything
    nZero = sum(nix);
    ix(nix == 0,:) = true;
    nix(nix == 0) = size(ix,2);
    
    nums = 1:size(ix,2);
    inds = arrayfun(@(t) nums(ix(t,:)), 1:nt, 'uni', 0);
    Zsamp = cell2mat(arrayfun(@(t) Z1(inds{t}(randi(nix(t))),:), ...
        1:nt, 'uni', 0)');
end
