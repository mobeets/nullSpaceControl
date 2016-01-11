function [latents, A, b, Ainv, binv] = convertRawSpikesToRawLatents(simpleData,spikes)

% Convert spikes to latents
L  = simpleData.nullDecoder.FactorAnalysisParams.L;
ph = simpleData.nullDecoder.FactorAnalysisParams.ph;

mu    = simpleData.nullDecoder.spikeCountMean';
sigma = simpleData.nullDecoder.spikeCountStd';


% [N,T] = size(spikes);
% nspks = bsxfun(@plus, spikes, -mu) ./ repmat(sigma,1,T);
% latents = L' * inv(L*L'+diag(ph)) * nspks;


A = L' * inv(L*L'+diag(ph))*inv(diag(sigma));
b = A*(-mu);

Ainv = diag(sigma)*L;
binv = mu;

if isempty(spikes)
    latents = [];
else
    latents = bsxfun(@plus,A*spikes,b);
end
