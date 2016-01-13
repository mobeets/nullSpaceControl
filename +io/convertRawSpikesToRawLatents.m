function [latents, A, b, Ainv, binv] = convertRawSpikesToRawLatents(...
    decoder, spikes)
% Convert spikes to latents

if isempty(spikes)
    latents = [];
    return;
end

% FA params
L  = decoder.FactorAnalysisParams.L;
ph = decoder.FactorAnalysisParams.ph;
mu    = decoder.spikeCountMean';
sigma = decoder.spikeCountStd';

% See Eqn. 5 of DAP.pdf
A = L' * inv(L*L'+diag(ph))*inv(diag(sigma));
b = A*(-mu);
Ainv = diag(sigma)*L;
binv = mu;

Asp = L'*((L*L'+diag(ph))\(diag(sigma)\spikes));
latents = bsxfun(@plus, Asp, b);
% latents = bsxfun(@plus, A*spikes, b);

end
