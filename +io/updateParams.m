function ps = updateParams(ps, ps_new, doOverwrite)
    if nargin < 3
        doOverwrite = false;
    end
    fns = fieldnames(ps_new);
    for ii = 1:numel(fns)
        fn = fns{ii};
        if isfield(ps, fn) && ~doOverwrite
            continue;
        end
        ps.(fn) = ps_new.(fn);
    end
end
