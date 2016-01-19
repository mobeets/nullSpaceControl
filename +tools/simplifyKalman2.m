function [M0, M1, M2, k] = simplifyKalman2(kalmanParams)
% from tools.simplifyKalman for 'raw' 'factors'

    sigpr = kalmanParams.sig0;
    H = kalmanParams.H;
    Q = kalmanParams.Q;
    A = kalmanParams.A;
    d = kalmanParams.d;
    W = kalmanParams.W;
    b = kalmanParams.b;
    
    % kalman gain
    TIMESTEPS = 50;
    for i = 1:TIMESTEPS
        k = sigpr*H'*inv(H*sigpr*H'+Q);
        sigfi = sigpr - k*H*sigpr;
        sigpr = A*sigfi*A'+W;
    end

    factorMean = kalmanParams.FactorAnalysisParams.factorMean;
    sigma_z = diag(1./kalmanParams.FactorAnalysisParams.factorSTD);    
    
    M0 = b - k*sigma_z*factorMean - k*H*b - k*d;
    M1 = A - k*H*A;
    M2 = k*sigma_z;

end
