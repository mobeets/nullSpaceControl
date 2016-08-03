function Z = habContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 20, 'grpNm', 'thetaGrps', 'doSample', true, ...
        'obeyBounds', true, 'boundsType', 'marginal', ...
        'rotThetas', 0, 'boundsThresh', inf);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    ths = B2.(opts.thetaNm);
    gs = B2.(opts.grpNm);
    ngs = numel(unique(gs));
    
    if numel(opts.rotThetas) == 1
        opts.rotThetas = opts.rotThetas*ones(ngs,1);
    end

    Zr = B2.latents*(RB2*RB2');
    Zsamp = nan(nt,nn);
    
    YR1 = B1.latents*RB2;
    YN1 = B1.latents*NB2;
    
    isOutOfBounds = pred.boundsFcn(B1.latents, opts.boundsType, D);
    d = 0;
    for t = 1:nt
        isOutOfBndsNul = pred.boundsFcnCond(B2.latents(t,:)*RB2, ...
            YR1, YN1, opts.boundsThresh);
        
        rotTheta = opts.rotThetas(score.thetaCenters(ngs) == gs(t));
        Zsamp(t,:) = pred.randZIfNearbyTheta(ths(t), B1, ...
            opts.thetaTol, ~opts.doSample, false, rotTheta);
        
        c = 0;        
        while opts.obeyBounds && (isOutOfBounds(Zsamp(t,:)*(NB2*NB2') + ...
                Zr(t,:)) || isOutOfBndsNul(Zsamp(t,:)*NB2)) && c < 10
            Zsamp(t,:) = pred.randZIfNearbyTheta(ths(t), B1, ...
                opts.thetaTol, ~opts.doSample);
            c = c + 1;
        end
        if c > 1 && c < 10
            d = d + 1;
        end
%         Zr(t,:) = pred.rowSpaceFit(B2, B2.fDecoder, NB2, RB2, t);
    end
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ' habitual samples to lie within bounds']);
    end
    Zn = Zsamp*(NB2*NB2');
    Z = Zr + Zn;

end
