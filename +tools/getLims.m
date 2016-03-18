function lm = getLims(vs, pctMrg)
    if nargin < 2
        pctMrg = 0;
    end    
    lm(1) = min(vs);
    lm(2) = max(vs);
    mrg = pctMrg*range(lm);
    lm(1) = lm(1) - mrg;
    lm(2) = lm(2) + mrg;
end
