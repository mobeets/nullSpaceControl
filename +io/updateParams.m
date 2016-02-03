function ps = updateParams(ps, ps_new)
    fns = fieldnames(ps_new);
    for ii = 1:numel(fns)
        fn = fns{ii};
        ps.(fn) = ps_new.(fn);
    end
end
