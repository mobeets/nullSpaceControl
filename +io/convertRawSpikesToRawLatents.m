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
    Asp = top\(diag(sigma)\spikes);
    b = top\(diag(sigma)\-mu);
    latents = bsxfun(@plus, L'*Asp, L'*b);
    
end
