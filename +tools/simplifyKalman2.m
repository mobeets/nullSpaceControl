function [M0, M1, M2, k] = simplifyKalman2(kalmanParams)
% from tools.simplifyKalman for 'raw' 'factors'
    
    H = kalmanParams.H;
    A = kalmanParams.A;
    d = kalmanParams.d;
    b = kalmanParams.b;
    
    % kalman gain - kalmanParams.convergedKalmanGain
    if isfield(kalmanParams, 'convergedKalmanGain')
        k = kalmanParams.convergedKalmanGain;
    else        
        Q = kalmanParams.Q;
        W = kalmanParams.W;
        sigpr = kalmanParams.sig0;
        k = getConvergedKalmanGain(sigpr, H, Q, A, W);
    end

    factorMean = kalmanParams.FactorAnalysisParams.factorMean;
    sigma_z = diag(1./kalmanParams.FactorAnalysisParams.factorSTD);
    
    M0 = b - k*sigma_z*factorMean - k*H*b - k*d;
    M1 = A - k*H*A;
    M2 = k*sigma_z;

end

function getConvergedKalmanGain(sigpr, H, Q, A, W)
    TIMESTEPS = 50;
    for i = 1:TIMESTEPS
        k = sigpr*H'*inv(H*sigpr*H'+Q);
        sigfi = sigpr - k*H*sigpr;
        sigpr = A*sigfi*A'+W;
    end
end
