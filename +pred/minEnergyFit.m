function Z = minEnergyFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'nDecoder', 'minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~opts.fitInLatent && strcmp(opts.decoderNm(1), 'f')
        warning('minEnergyFit must use spike decoder, not factors.');
        opts.decoderNm(1) = 'n';
    elseif opts.fitInLatent && strcmp(opts.decoderNm(1), 'n')
        warning('minEnergyFit must use factor decoder, not spikes.');
        opts.decoderNm(1) = 'f';
    end    
    
    % set upper and lower bounds
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    if opts.fitInLatent
        Y1 = B1.latents;
        Y2 = B2.latents;
    else
        Y1 = B1.spikes;
        Y2 = B2.spikes;
    end
    lb = min(Y1); ub = max(Y1);
    
    % set minimum, in latent or spike space
    Dc = D.simpleData.nullDecoder;
    if strcmpi(opts.minType, 'baseline') && opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'baseline') && ~opts.fitInLatent
        mu = Dc.spikeCountMean;        
    elseif strcmpi(opts.minType, 'minimum') && opts.fitInLatent        
        zers = zeros(size(D.blocks(1).spikes,2), 1);
        mu = tools.convertRawSpikesToRawLatents(Dc, zers);
    elseif strcmpi(opts.minType, 'minimum') && ~opts.fitInLatent
        mu = [];
    end    

    [nt, nu] = size(Y2);
    U = nan(nt,nu);
    for t = 1:nt
        if mod(t, 500) == 0
            disp(['minEnergyFit: ' num2str(t) ' of ' num2str(nt)]);
        end
        U(t,:) = pred.quadFireFit(B2, t, -mu, B2.(opts.decoderNm), ...
            opts.fitInLatent, lb, ub);
    end
    if opts.fitInLatent
        Z = U;
    else
        Z = tools.convertRawSpikesToRawLatents(Dc, U'); 
    end
    if opts.nanIfOutOfBounds
        opts.isOutOfBounds = pred.boundsFcn(B1.latents);
        isOut = arrayfun(@(t) opts.isOutOfBounds(Z(t,:)), 1:nt);
        Z(isOut,:) = nan;
        c = sum(isOut);
        if c > 0
            warning(['minEnergyFit ignoring ' num2str(c) ...
                ' points outside of bounds.']);
        end
    end
end