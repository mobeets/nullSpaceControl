function [prms, grps, nms] = quickBehavior(D, behavNm, grpName, flipSign)
% returns behavior metrics in perturbation block
%
%   prms [ngrps nflds]
%       prms(ii,:) = [yStart yEnd tau xThresh Lmax Lbest lrn]
%
    if nargin < 3
        grpName = '';
    end
    if nargin < 4
        flipSign = false;
    end
    binSz = 100; ptsPerBin = 4;
    nms = {'yEnd', 'yStart', 'tau', 'yDiff', 'yDiffPct', 'xThresh', ...
        'Lmax', 'Lbest', 'lrn'};
    signInds = [4 5 7 8];
    
    [Y,X,~,grps] = tools.behaviorByTrial(D, behavNm, ...
        0, grpName, binSz, ptsPerBin, true);
    ngrps = numel(grps);
    prms = nan(ngrps,numel(nms));
    for ii = 1:ngrps
        xc = X{ii,2};
        yc = Y{ii,2};        
        [ps, xth] = tools.satExpFit(xc, yc);
        yDiff = ps(1) - ps(2);
        yDiffPct = yDiff/ps(2);
        
        yc1 = Y{ii,1};
        [Lmax, Lbest, ~] = plot.learningOneKin(yc1, yc);
        lrn = Lbest/Lmax;
        prms(ii,:) = [ps yDiff yDiffPct xth Lmax Lbest lrn];
    end
    if flipSign
        prms(:,signInds) = -1*prms(:,signInds);
    end
end
