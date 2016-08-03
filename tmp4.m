function sps = latentsHaveValidSpikes(latents, D)

    minSps = 0;
    maxSps = 2*max(max(D.trials.spikes));

    decoder = D.simpleData.nullDecoder;
    if isfield(decoder.FactorAnalysisParams, 'spikeRot')
        % latents need rotating into new space
        latents = latents/decoder.FactorAnalysisParams.spikeRot;
    end

    L = decoder.FactorAnalysisParams.L;    
    ph = decoder.FactorAnalysisParams.ph;
    mu = decoder.spikeCountMean';
    sigma = decoder.spikeCountStd';
    beta = L'/(L*L'+diag(ph));
    A = beta/diag(sigma);

    nt = size(latents,1);
    nneurs = size(L,1);
    const = ones(nneurs,1);
    lb = minSps*const;
    ub = maxSps*const;

    sps = nan(nt, nneurs);
    for ii = 1:nt
        lts = latents(ii,:);
        [X,FVAL,EXITFLAG,OUTPUT] = linprog([], [], [], A, lts' + A*mu, ...
            lb, ub, [], optimset('Display', 'off'));
        if EXITFLAG == 1
            sps(ii,:) = X;
        else
            warning(['Error for ' num2str(ii)]);
        end
    end
end
