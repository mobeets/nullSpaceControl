function [nullMs, shuffleMs] = getMs_forLatents(simpleData, kalmanInitParams)
%
% OUTPUT:
% nullMs struct
% nullMs.M0, .M1, .M2 are appropriate for decoding with raw factors during the null block
%
% shuffleMs struct analogous for shuffle block


% Get simple data, which has shuffle information
shuffle = simpleData.shuffles.shuffles;

% Load original parameter file
[M2, M1, M0, beta, k] = simplifyKalman(kalmanInitParams, 'raw', 'factors');

nullMs.M0 = M0;
nullMs.M1 = M1;
nullMs.M2 = M2;

% Get parameters necessary to compute shuffle parameters
for i = 1:length(shuffle)
    eta_f(i,shuffle(i)) = 1;
end

Sigma_z = diag(1./simpleData.nullDecoder.FactorAnalysisParams.factorStd);

d = kalmanInitParams.d;

shuffleMs.M0 = -k*d;
shuffleMs.M1 = nullMs.M1;
shuffleMs.M2 = k*eta_f*Sigma_z;