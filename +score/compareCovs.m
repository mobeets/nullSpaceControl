function [s, s2, s3] = compareCovs(D1, D2)
% src: "A simple procedure for the comparison of covariance matrices"
% http://bmcevolbiol.biomedcentral.com/articles/10.1186/1471-2148-12-222
% 
% s = s2 + s3 = 0 if cov(D1) and cov(D2) have the same orientation/shape
% s2 = 0 iff cov(D1) and cov(D2) have same orientation
% s3 = 0 iff cov(D1) and cov(D2) have same shape
% 

    if any(any(isnan(cov(D1)))) || any(any(isnan(cov(D2))))
        s = nan; s2 = nan; s3 = nan;
        return;
    end
    [u1,v11,~] = svd(cov(D1), 'econ');
    [u2,v22,~] = svd(cov(D2), 'econ');
    v11 = diag(v11)'; % var(D1*u1);
    v22 = diag(v22)'; % var(D2*u2);
    v21 = var(D2*u1);
    v12 = var(D1*u2);
    s = 2*sum((v11 - v21).^2 + (v12 - v22).^2); % s = s2 + s3
    s2 = sum(((v11 + v22) - (v12 + v21)).^2); % orientation
    s3 = sum(((v11 + v12) - (v21 + v22)).^2); % shape
    
    smax = 4*(sum(var(D1))^2 + sum(var(D2))^2);
    assert(s <= smax && s2 <= smax && s3 <= smax);
    s = s./smax;
    s2 = s2./smax;
    s3 = s3./smax;    
end

% || v11 - v21 ||^2 + || v12 - v22 ||^2 = overall
% || (v11 - v12) + (v22 - v21) ||^2 = orientation
