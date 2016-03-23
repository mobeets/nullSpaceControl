function spikes = latentsToSpikes(latents, decoder, addNoise)
% generate spikes s.t. the model from spikes to latents recreates the
%   present latents
% 

    if nargin < 3
        addNoise = false;
    end

    if isfield(decoder.FactorAnalysisParams, 'spikeRot')
        latents = latents/decoder.FactorAnalysisParams.spikeRot;
    end
    L = decoder.FactorAnalysisParams.L;
    ph = decoder.FactorAnalysisParams.ph;    

%     top = (L*L'+diag(ph));
%     ((L'*inv(top))*U)' = U'*(L'*inv(top))' = U'*(top'\L) = Z'
%     U = latents*(L\top');
%     U = latents*(L + diag(ph)/L')';

    % note that the generative model for spikes is:
    % U = latents*L';
    %   but this won't result in the decoded latents from those spikes
    %   being identical to the latents we have here...
    
    L = L + diag(ph)/L';
    U = latents*L';
    
    if addNoise
        nse = mvnrnd(zeros(size(U,2),1), ph', size(U,1));
        U = U + nse;
    end
    mu = decoder.spikeCountMean;
    sigma = decoder.spikeCountStd;
    spikes = bsxfun(@plus, U*diag(sigma), mu);
end
