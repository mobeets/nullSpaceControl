function stats = imeStats(Blk, estParams, opts)

    T_START = opts.TAU + 2;
    [U, Y, Xtarget] = imefit.prep(Blk, opts.doLatents);    
    [mdlErrs, cErrs, result, by_trial] = imefit.imeErrs(U, Y, Xtarget, ...
        estParams, opts.TARGET_RADIUS, T_START);
    stats.mdlErrs = mdlErrs;
    stats.cErrs = cErrs;
    stats.result = result;
    stats.by_trial = by_trial;
end
    