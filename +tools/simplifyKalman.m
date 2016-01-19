function [M2 M1 M0 beta k] = simplifyKalman(kalmanParams,inputMode,inputSignal,varargin)

TIMESTEPS = 50;                 % default is to use 50 timesteps for calculating the converged kalman gain
IGNORESTATEMODEL = false;       % default is to include the state model
NEURONSHUFFLE = [];             % default is to calculate these parameters without a neuron shuffle
FACTORSHUFFLE = [];             % default is to calculate these parameters without a factor shuffle
ORTHONORMALIZE = false;         % default is to not orthonormalize the factors; this only is applicable when the input is raw factors

varRemain = assignopts('ignorecase', who, varargin);

if ~isempty(varRemain)
    fprintf('\n\n')
    disp('The following optional arguments were invalid (simplifyKalman.m):')
    disp(varRemain)
    disp('Press any key to continue')
    pause
end

%% make sure the inputs are valid
if xor(isempty(NEURONSHUFFLE),isempty(FACTORSHUFFLE))
    if ~strcmp(inputSignal,'spikes')
        fprintf('The input must be spikes for a shuffled decoder.\r')
        M2 = []; M1 = []; M0 = [];
        return
    end
elseif ~isempty(NEURONSHUFFLE) && ~isempty(FACTORSHUFFLE)
    fprintf('NEURONSHUFFLE and FACTORSHUFFLE may not both be used in the same decoder.\r')
    M2 = []; M1 = []; M0 = [];
    return
end

%% get the kalman filter parameters
sigpr = kalmanParams.sig0;
H = kalmanParams.H;
Q = kalmanParams.Q;
A = kalmanParams.A;
d = kalmanParams.d;
W = kalmanParams.W;
if ~isfield(kalmanParams,'b')
    b = zeros(size(A,1),1);
else
    b = kalmanParams.b;
end

if size(d,1) == 1; d = d'; end
if size(b,1) == 1; b = b'; end

if isempty(d);
    d = zeros(size(H,1),1);
end

%% get the converged kalman gain
if ~IGNORESTATEMODEL
    for i = 1:TIMESTEPS
        k = sigpr*H'*inv(H*sigpr*H'+Q);
        sigfi = sigpr - k*H*sigpr;
        sigpr = A*sigfi*A'+W;
    end
else
    % Compute converged Kalman gain when state transition model is ignored
    % (i.e. Q-->infinity).  This is equivalent to the OLE decode matrix.
    k = inv(H'*inv(Q)*H)*H'*inv(Q);
end

%% get the spike count statistics
if isfield(kalmanParams,'NormalizeSpikes')
    if ~isempty(kalmanParams.NormalizeSpikes.mean)
        spikeCountMean = kalmanParams.NormalizeSpikes.mean;
        if size(spikeCountMean,1) == 1; spikeCountMean = spikeCountMean'; end
        spikeCountSTD = kalmanParams.NormalizeSpikes.std;
        if size(spikeCountSTD,1) == 1; spikeCountSTD = spikeCountSTD'; end
    else
        spikeCountMean = zeros(size(k,2),1);
        spikeCountSTD = ones(size(k,2),1);
    end
else
    spikeCountMean = zeros(size(k,2),1);
    spikeCountSTD = ones(size(k,2),1);
end
sigma_u = diag(1./spikeCountSTD);

%% get the FA parameters and factor statistics
if isfield(kalmanParams,'FactorAnalysisParams')
    if ~strcmp(kalmanParams.FactorAnalysisParams.FAmode,'none')
        if ~isempty(kalmanParams.FactorAnalysisParams.L) && ...
                ~strcmp(kalmanParams.FactorAnalysisParams.FAmode,'complex')
            L = kalmanParams.FactorAnalysisParams.L;
            mu = kalmanParams.FactorAnalysisParams.d;
            if size(mu,1) == 1; mu = mu'; end
            if isfield(kalmanParams.FactorAnalysisParams,'Ph')
                ph = kalmanParams.FactorAnalysisParams.Ph;
            else
                ph = kalmanParams.FactorAnalysisParams.phi;
            end

            if isfield(kalmanParams.FactorAnalysisParams,'factorMean')
                factorMean = kalmanParams.FactorAnalysisParams.factorMean;
                if size(factorMean,1) == 1; factorMean = factorMean'; end
                factorSTD = kalmanParams.FactorAnalysisParams.factorSTD;
                if size(factorSTD,1) == 1; factorSTD = factorSTD'; end
            else
                factorMean = zeros(size(kalmanParams.FactorAnalysisParams.factorMean,1),1);
                factorSTD = ones(size(kalmanParams.FactorAnalysisParams.factorMean,1),1);
            end
            sigma_z = diag(1./factorSTD);

            beta = L'*inv(L*L'+diag(ph));
        else
            fprintf('Invalid factor analysis parameters.\r')
            keyboard
        end
        kalmanFA = true; % this is a kalmanFA decoder, not regular kalman
    else
        kalmanFA = false;
    end
else
    kalmanFA = false; % this is a regular kalman filter, not kalmanFA
end

%% get the shuffle parameters
if ~isempty(NEURONSHUFFLE)
    N_n = zeros(length(spikeCountMean));
    for nrnIdx = 1:length(spikeCountMean)
        N_n(nrnIdx,NEURONSHUFFLE(nrnIdx)) = 1;
    end
    N_f = [];
    shuffleType = 'neuron';
elseif ~isempty(FACTORSHUFFLE)
    N_f = zeros(length(factorMean));
    for factIdx = 1:length(factorMean)
        N_f(factIdx,FACTORSHUFFLE(factIdx)) = 1;
    end
    N_n = [];
    shuffleType = 'factor';
else
    N_f = [];
    N_n = [];
    shuffleType = 'none';
end

%% simplify the parameters
if ~IGNORESTATEMODEL
    M1 = A - k*H*A;
else
    M1 = zeros(size(A));
end

if kalmanFA
    if strcmp(inputSignal,'spikes') && strcmp(inputMode,'raw')
        switch shuffleType
            case 'none'
                M2 = k*sigma_z*beta*sigma_u;
                M0 = b - k*sigma_z*beta*sigma_u*spikeCountMean - k*sigma_z*beta*mu - ...
                    k*sigma_z*factorMean - k*H*b - k*d;
            case 'factor'
                M2 = k*N_f*sigma_z*beta*sigma_u;
                M0 = b - k*N_f*sigma_z*beta*sigma_u*spikeCountMean - k*N_f*sigma_z*beta*mu - ...
                    k*N_f*sigma_z*factorMean - k*H*b - k*d;
            case 'neuron'
                M2 = k*sigma_z*beta*N_n*sigma_u;
                M0 = b - k*sigma_z*beta*N_n*sigma_u*spikeCountMean - k*sigma_z*beta*N_n*mu - ...
                    k*sigma_z*factorMean - k*H*b - k*d;
        end
    elseif strcmp(inputSignal,'spikes') && strcmp(inputMode,'normalized')
        switch shuffleType
            case 'none'; M2 = k*sigma_z*beta;
            case 'factor'; M2 = k*N_f*sigma_z*beta;
            case 'neuron'; M2 = k*sigma_z*beta*N_n;
        end
        M0 = b - k*sigma_z*beta*mu - k*sigma_z*factorMean - k*H*b - k*d;
    elseif strcmp(inputSignal,'factors') && strcmp(inputMode,'raw')
        if ORTHONORMALIZE
            [~,~,V] = svd(L,'econ');
            M2 = k*sigma_z*V;
        else
            M2 = k*sigma_z;
        end
        M0 = b - k*sigma_z*factorMean - k*H*b - k*d;
    elseif strcmp(inputSignal,'factors') && strcmp(inputMode,'normalized')
        M2 = k;
        M0 = b - k*H*b - k*d;
    else
        fprintf('invalid inputSignal and inputMode combination for kalmanFA')
        return
    end
else
    if strcmp(inputSignal,'spikes') && strcmp(inputMode,'raw')
        M2 = k*sigma_u;
        M0 = b - k*sigma_u*spikeCountMean - k*H*b - k*d;
    elseif strcmp(inputSignal,'spikes') && strcmp(inputMode,'normalized')
        M2 = k;
        M0 = b - k*H*b - k*d;
    else
        fprintf('invalid inputSignal and inputMode combination for regular Kalman filter.\r')
        return
    end
end