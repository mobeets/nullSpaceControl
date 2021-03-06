function [s, s2, s3] = compareCovs(D1, D2, doNormalize)
% src: "A simple procedure for the comparison of covariance matrices"
% http://bmcevolbiol.biomedcentral.com/articles/10.1186/1471-2148-12-222
% 
% s = s2 + s3 = 0 if cov(D1) and cov(D2) have the same orientation/shape
% s2 = 0 iff cov(D1) and cov(D2) have same orientation
% s3 = 0 iff cov(D1) and cov(D2) have same shape
%
% if doNormalize, then s,s2,s3 are scaled to be in [0,1]
%       if D2 predicts D1 better than 0-matrix
% 
    if nargin < 3
        doNormalize = true;
    end
    if any(any(isnan(cov(D1)))) || any(any(isnan(cov(D2))))
        s = nan; s2 = nan; s3 = nan;
        return;
    end
    [u1,v11,~] = svd(nancov(D1), 'econ');
    [u2,v22,~] = svd(nancov(D2), 'econ');
    v11 = diag(v11)'; % var(D1*u1);
    v22 = diag(v22)'; % var(D2*u2);
    v21 = nanvar(D2*u1);
    v12 = nanvar(D1*u2);
    s = 2*sum((v11 - v21).^2 + (v12 - v22).^2); % s = s2 + s3
    s2 = sum(((v11 + v22) - (v12 + v21)).^2); % orientation
    s3 = sum(((v11 + v12) - (v21 + v22)).^2); % shape
    
    if doNormalize
%         [~,~,v] = svd(D1, 'econ');
%         Dworse = zeros(size(D1)); Dworse(:,1) = 1e7*randn(size(D1,1),1);
%         smax = score.compareCovs(D1, Dworse*v', false);
        smax = score.compareCovs(D1, zeros(size(D1)), false);
%         smax = 4*(sum(var(D1))^2 + sum(var(D2))^2) + 1e-5;
%         assert(s <= smax && s2 <= smax && s3 <= smax, num2str([s s2 s3 smax]));
        s = s./smax;
        s2 = s2./smax;
        s3 = s3./smax;
    end
end

% || v11 - v21 ||^2 + || v12 - v22 ||^2 = overall
% || (v11 - v12) + (v22 - v21) ||^2 = orientation
