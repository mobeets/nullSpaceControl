function Z = uncContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'obeyBounds', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    
    B1 = D.blocks(1);
    mns = min(B1.latents);
    mxs = max(B1.latents);
    isOutOfBounds = @(z, mns, mxs) all(isnan(z)) || ...
        (sum(z < mns) > 0 || sum(z > mxs) > 0);

    % sample Z uniformly from B1 for each time point
    ntB1 = size(B1.latents,1);
    Zsamps = B1.latents(randi(ntB1, nt, 1),:);
    Zn = Zsamps*(NB2*NB2');
    Zr = B2.latents*(RB2*RB2');
    
    % correct to be within bounds defined by B1
    if opts.obeyBounds        
        c = 0;
        isOutBnds = arrayfun(@(t) isOutOfBounds(Zn(t,:)+Zr(t,:), ...
            mns, mxs), 1:nt);
        ntc = sum(isOutBnds);
        d = ntc;
        while ntc > 0 && c < 10
            Zsamps(isOutBnds,:) = B1.latents(randi(ntB1, ntc, 1),:);
            Zn = Zsamps*(NB2*NB2');
            isOutBnds = arrayfun(@(t) isOutOfBounds(Zn(t,:)+Zr(t,:), ...
                mns, mxs), 1:nt);
            ntc = sum(isOutBnds);
            c = c + 1;
        end        
        d = d - ntc; % number we were able to correct
    end
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ...
            ' unconstrained samples to lie within bounds']);
    end
        
    Z = Zr + Zn;
end
