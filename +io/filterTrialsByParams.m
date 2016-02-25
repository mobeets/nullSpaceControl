function trials = filterTrialsByParams(trials, params)
    
    ix = abs(trials.angError) < params.MAX_ANGULAR_ERROR & ...
        trials.rs >= params.MIN_DISTANCE & ...
        trials.rs <= params.MAX_DISTANCE;
    trials = io.filterTrialsByIdx(trials, ix);
    
    % filter out shuffle and washout trials prior to 'START_' params
    if ~isnan(params.START_SHUFFLE)
        ixb = trials.block_index == 2;
        ixt = trials.trial_index <= params.START_SHUFFLE;
        trials.block_index(ixb & ixt) = nan;
    end
    if ~isnan(params.START_WASHOUT)
        ixb = trials.block_index == 3;
        ixt = trials.trial_index <= params.START_WASHOUT;
        trials.block_index(ixb & ixt) = nan;
    end

end
