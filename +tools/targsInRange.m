function ix = targsInRange(targs, bnds)
    if bnds(1) <= bnds(2)
        ix = targs >= bnds(1) & targs <= bnds(2);
    else % e.g. [337.5 22.5]
        ix = targs >= bnds(1) | targs <= bnds(2);
    end
end
