function lm = getLims(vs, pctMrg, axNum)
    if nargin < 2
        pctMrg = 0;
    end
    if nargin < 3
        axNum = 1;
    end
    
    lm(1) = min(vs(:,axNum));
    lm(2) = max(vs(:,axNum));
    mrg = pctMrg*range(lm);
    lm(1) = lm(1) - mrg;
    lm(2) = lm(2) + mrg;
end
