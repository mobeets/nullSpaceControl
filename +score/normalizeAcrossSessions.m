function scs = normalizeAcrossSessions(scs, hypInd)
    if nargin < 2
        hypInd = nan; % if not nan, normalize to this hyp's errors
    end

    if isnan(hypInd)
        mn = min(scs,[],2);
        mx = max(scs,[],2) - mn;
        scs = bsxfun(@rdivide, bsxfun(@plus, scs, -mn), mx);
    else
        scs = bsxfun(@rdivide, scs, scs(:,hypInd));
    end

end
