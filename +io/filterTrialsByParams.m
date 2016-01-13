function trials = filterTrialsByParams(trials, params)
    
    ix = abs(trials.angError) < params.MAX_ANGULAR_ERROR & ...
        trials.rs >= params.MIN_DISTANCE & ...
        trials.rs <= params.MAX_DISTANCE;
    trials = io.filterTrialsByIdx(trials, ix);

end
