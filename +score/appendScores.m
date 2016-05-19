function D = appendScores(D, objs, fldNm)
    if isfield(D, fldNm)
        scs = D.(fldNm);
        [nreps, nhyps] = size(scs);
        if nhyps ~= numel(objs)
            error('New hyp added. You must drop old ones.');
        end
        scs(nreps+1,:) = objs;
    else
        scs = objs;
    end
    D.(fldNm) = scs;
end
