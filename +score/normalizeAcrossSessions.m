function scs = normalizeAcrossSessions(scs)

    mn = min(scs,[],2);
    mx = max(scs,[],2) - mn;
    scs = bsxfun(@rdivide, bsxfun(@plus, scs, -mn), mx);

end
