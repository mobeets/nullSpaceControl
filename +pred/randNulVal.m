function Z = randNulVal(D, opts)
% choose intuitive pt within thetaTol
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', ...
        'obeyBounds', false, 'boundsType', 'marginal');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    Z1 = B1.latents;
    Z2 = B2.latents;    
    
    Zsamp = Z1(randi(size(Z1,1),size(Z2,1),1),:);
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
            Zsamp = Z1(randi(size(Z1,1),sum(ixOob),1),:);
            Z(ixOob,:) = Zr(ixOob,:) + Zsamp*(NB2*NB2');
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            warning(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' unconstrained samples to lie within bounds']);
        end
    end

end
