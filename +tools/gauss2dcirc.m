function [bp, mu, sigma] = gauss2dcirc(data, sigMult)
% data [n x 2]
% plot(bp(1,:), bp(2,:)) will plot a circle
% 
    if nargin < 2
        sigMult = 1;
    end

    mu = mean(data)';
    sigma = cov(data);
    tt = linspace(0, 2*pi, 30)';
    x = cos(tt); y = sin(tt);
    ap = [x(:) y(:)]';
    [v,d] = eig(sigma);
    d = sigMult*sqrt(d);
    bp = (v*d*ap) + repmat(mu, 1, size(ap,2)); 

end
