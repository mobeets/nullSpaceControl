function hyp = getHyp(D, name)
    if ~isfield(D, 'hyps')
        hyp = []; return;
    end
    ix = strcmp({D.hyps.name}, name);
    if not(any(ix))
        hyp = []; return;
    end
    hyp = D.hyps(ix);
end
