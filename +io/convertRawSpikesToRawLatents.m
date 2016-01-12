function [latents, A, b, Ainv, binv] = convertRawSpikesToRawLatents(d, ...
    spikes)

% Convert spikes to latents
L  = d.simpleData.nullDecoder.FactorAnalysisParams.L;
ph = d.simpleData.nullDecoder.FactorAnalysisParams.ph;
mu    = d.simpleData.nullDecoder.spikeCountMean';
sigma = d.simpleData.nullDecoder.spikeCountStd';

A = L' * inv(L*L'+diag(ph))*inv(diag(sigma));
b = A*(-mu);
Ainv = diag(sigma)*L;
binv = mu;

if isempty(spikes)
    latents = [];
else
    latents = bsxfun(@plus, A*spikes, b);
end
