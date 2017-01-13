function [isGood, ixs, xsb, ysb, ysv] = plotThreshTrials(xs, ys, opts)
    defopts = struct('muThresh', 0.5, 'varThresh', 0.5, ...
        'meanBinSz', 50, 'varBinSz', 50, 'varMeanBinSz', 50, ...
        'trialsInARow', 10, 'groupEvalFcn', @numel, ...
        'minGroupSize', 100);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % get mean value per trial
    xsb = unique(xs);
    ysb = grpstats(ys, xs);
    if numel(ysb) < opts.meanBinSz
        isGood = []; ixs = {}; xsb = []; ysb = []; ysv = []; return;
    end
    
    % get smoothed mean and smoothed running var
%     ysv = runningVar(ysb, opts.varBinSz);
%     ysv = smooth(ysv, opts.meanBinSz);
    ysb0 = ysb;
    ysb = smooth(xsb, ysb, opts.meanBinSz);
    ymn = nanmin(ysb(26:end-10));
    ymx = max(ysb(1:25));
    ysb2 = smooth(xsb, ysb0, opts.varMeanBinSz);
    ysv = runningVar(ysb2, opts.varBinSz);
    
    % normalize mean and var to be in [0,1]    
    ysb = behav2.normToZeroOne(ysb, ymn, ymx);    
%     ysv = behav2.normToZeroOne(ysv, nanmin(ysv), nanmax(ysv));
    vmn = nanmin(ysv);
    vmx = nanmax(ysv(1:ceil(numel(ysv)/2)));
    ysv = behav2.normToZeroOne(ysv, vmn, vmx);
    
    % find best set of consecutive trials below threshold for mean and var
    ix1 = ysb <= opts.muThresh;
    ix2 = ysv <= opts.varThresh;
    ix = ix1 & ix2;
    ix1 = findBestRun(xsb, ysb, ix1, opts.groupEvalFcn, opts.trialsInARow);
    ix2 = findBestRun(xsb, ysb, ix2, opts.groupEvalFcn, opts.trialsInARow);
    ix = findBestRun(xsb, ysb, ix, opts.groupEvalFcn, opts.trialsInARow);
    ixs = {ix, ix1, ix2};
    
    isGood = [];
    isGood(1) = numel(ysb(~isnan(ysb))) > 0;
    isGood(2) = true; % tTestOfBestAgainstFirst(ysb, Ysc) <= 0.05;
    if sum(ix) == 0
        isGood(3) = false;
    else
        isGood(3) = max(xsb(ix))-min(xsb(ix)) >= opts.minGroupSize;
    end
end

function v = runningVar(x, m)
    n=size(x,1);
    f=zeros(m,1)+1/m;
    v=filter2(f,x.^2,'valid')-filter2(f,x,'valid').^2;
    m2=floor(m/2);
    n2=ceil(m/2)-1;
    v=v([zeros(1,m2)+m2+1,(m2+1):(n-n2),zeros(1,n2)+(n-n2)]-m2,:);
    assert(isequal(numel(v), numel(x)));
end

% function p = tTestOfBestAgainstFirst(ysb, Ysc)
%     [~,ix] = min(ysb);
%     Y1 = Ysc{1};
%     Y2 = Ysc{ix};
%     % test Y1 > Y2
%     [~,p] = ttest2(Y1, Y2, 'Vartype', 'unequal', 'tail', 'right');
% end

function ixBest = findBestRun(xs, ys, ix, evalFcn, trialsInARow)
    % for groups of consecutive xs, find best set of corresponding ys
    xsc = xs(ix);
    ysc = ys(ix);
    temp = abs(diff(xsc));
    inds = [1 find(temp > trialsInARow)' numel(xsc)];
    ymx = -inf;
    bestInds = [];
    for kk = 2:numel(inds)
       ixc = (inds(kk-1)+1):inds(kk);
       ycur = evalFcn(ysc(ixc));
       if ycur > ymx
           ymx = ycur;
           bestInds = ixc;
       end
    end
    
    % make mask same size as ix, but with bestInds marked
    yx = double(ix);
    yx(ix>0) = 1:sum(ix>0);
    ixBest = ismember(yx, bestInds);
end

