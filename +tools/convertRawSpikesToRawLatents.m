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
    sigmainv = diag(1./decoder.spikeCountStd');
    if isfield(decoder.FactorAnalysisParams, 'spikeRot')
        R = decoder.FactorAnalysisParams.spikeRot;
    else
        R = eye(size(L,2));
    end
    
    beta = L'/(L*L'+diag(ph)); % See Eqn. 5 of DAP.pdf
    u = sigmainv*(bsxfun(@plus, spikes, -mu)); % normalize
%     u = spikes;
%     u = sigmainv*spikes;
    latents = (beta*u)';
    latents = latents*R; % rotate, if necessary, from orthonormalization

end
