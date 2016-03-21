function spikes = latentsToSpikes(latents, decoder, addNoise)
    if nargin < 3
        addNoise = false;
    end
    
    L = decoder.FactorAnalysisParams.L;
    ph = decoder.FactorAnalysisParams.ph;    
    spikes = (L*latents')';
    if addNoise
        nse = mvnrnd(zeros(size(spikes,2),1), ph', size(spikes,1));
        spikes = spikes + nse;
    end
    mu = decoder.spikeCountMean;
    sigma = decoder.spikeCountStd;
    spikes = bsxfun(@plus, spikes*diag(sigma), mu);
end
