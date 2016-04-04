function [mubar, Sbar] = condGaussMean(mu, S, ixUnknown)
% conditional mean and cov of a gaussian, given indices in ix
    
%     k = 2;
%     ix1 = (k+1):numel(mu);
%     ix2 = 1:k;
    ix1 = ixUnknown;
    ix2 = ~ix1;

    mu1 = mu(ix1)';
    mu2 = mu(ix2)';
    S11 = S(ix1,ix1);
    S12 = S(ix1,ix2);
    S22 = S(ix2,ix2);
    S21 = S(ix2,ix1);

    mubar = @(a) mu1 + (S12*(S22\(a - mu2)));
    Sbar = S11 - S12*(S22\S21);
end
