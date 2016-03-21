function latents = convertRawSpikesToRawLatents(decoder, spikes)
% Convert spikes to latents

    if isempty(spikes)
        latents = [];
        return;
    end

    % FA params
    L = decoder.FactorAnalysisParams.L;
    
    ph = decoder.FactorAnalysisParams.ph;
    mu = decoder.spikeCountMean';
    sigma = decoder.spikeCountStd';

    % See Eqn. 5 of DAP.pdf
    top = (L*L'+diag(ph));
    u = diag(sigma)\(bsxfun(@plus, spikes, -mu)); % normalize
    latents = (L'*(top\u))';
    
    if isfield(decoder.FactorAnalysisParams, 'spikeRot')
        % latents need rotating into new space
        latents = latents*decoder.FactorAnalysisParams.spikeRot;
    end
    
end
