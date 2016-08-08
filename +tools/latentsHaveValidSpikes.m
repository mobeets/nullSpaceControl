function [sps, isValid] = latentsHaveValidSpikes(latents, D)
% for each latent (lts), solves for spikes (sps) such that:
%   A*sps = lts + A*mu
%      s.t. lb <= sps <= ub
%
%   i.e., beta*zs = lts
%      where zs = inv(diag(sigma))*(sps - mu) is just the z-scored sps
%

    minSps = 0;
    maxSps = max(D.trials.spikes)';

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
    ub = maxSps;%*const;

    sps = nan(nt, nneurs);
    for ii = 1:nt
        lts = latents(ii,:);
        [X,~,EXITFLAG,~] = linprog([], [], [], A, lts' + A*mu, ...
            lb, ub, [], optimset('Display', 'off'));
        if EXITFLAG == 1
            sps(ii,:) = X;
        end
    end
    isValid = ~any(isnan(sps),2);
end
