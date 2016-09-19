function [latents, beta] = convertRawSpikesToRawLatents(decoder, spikes)
% Convert spikes to latents

    if isempty(spikes)
        latents = [];
        return;
    end

    % FA params
    L = decoder.FactorAnalysisParams.L;
    ph = decoder.FactorAnalysisParams.ph;
    mu = decoder.spikeCountMean';
    sigmainv = diag(1./decoder.spikeCountStd');
    if isfield(decoder.FactorAnalysisParams, 'spikeRot')
        % rotate, if necessary, from orthonormalization
        R = decoder.FactorAnalysisParams.spikeRot;
    else
        R = eye(size(L,2));
    end
    beta = L'/(L*L'+diag(ph)); % See Eqn. 5 of DAP.pdf
    beta = R'*beta*sigmainv';
    u = bsxfun(@plus, spikes, -mu); % normalize
    latents = (beta*u)';
end
