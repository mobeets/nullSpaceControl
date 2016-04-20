function [prms, grps, nms] = quickBehavior(D, behavNm, grpName, ...
    flipSign, collapseTrial)
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
    if nargin < 5
        collapseTrial = true;
    end
    if collapseTrial
        binSz = 20; minPtsPerBin = 1;
    else
        binSz = 100; minPtsPerBin = 4;
    end

    nms = {'yEnd', 'yStart', 'tau', 'yDiff', 'yDiffPct', 'xThresh', ...
        'Lmax', 'Lbest', 'lrn'};
    signInds = [4 5];% 7 8];
    
    [Y,X,~,grps] = tools.behaviorByTrial(D, behavNm, ...
        0, grpName, binSz, minPtsPerBin, collapseTrial);
    ngrps = numel(grps);
    prms = nan(ngrps,numel(nms));
    for ii = 1:ngrps
        xc = X{ii,2};
        yc = Y{ii,2};        
        [ps, xth] = tools.satExpFit(xc, yc);
        yDiff = ps(1) - ps(2);
        yDiffPct = yDiff/ps(2);
        
        xs = cell2mat(Y(ii,:)');
        bs = [ones(numel(Y{ii,1}),1); 2*ones(numel(Y{ii,2}),1); ...
            3*ones(numel(Y{ii,3}),1)];
        [Lbest, Lmax] = behav.singleLearnMaxAndRaw(xs, bs, flipSign, nan);
        
        lrn = Lbest/Lmax;
        prms(ii,:) = [ps yDiff yDiffPct xth Lmax Lbest lrn];
    end
    if flipSign
        prms(:,signInds) = -1*prms(:,signInds);
    end
end
