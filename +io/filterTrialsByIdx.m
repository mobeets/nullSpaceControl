function trials = filterTrialsByIdx(trials, ix)
    
    fns = fieldnames(trials);
    for ii = 1:numel(fns)
        val = trials.(fns{ii});
        trials.(fns{ii}) = val(ix,:);
    end

end
