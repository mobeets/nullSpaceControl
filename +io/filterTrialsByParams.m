function trials = filterTrialsByParams(trials, params)
    
    ix = true(size(trials.angError));
    if ~isnan(params.MIN_ANGULAR_ERROR)
        ix = ix & abs(trials.angError) >= params.MIN_ANGULAR_ERROR;
    end
    if ~isnan(params.MAX_ANGULAR_ERROR)
        ix = ix & abs(trials.angError) < params.MAX_ANGULAR_ERROR;
    end
    if ~isnan(params.MIN_DISTANCE)
        ix = ix & trials.rs >= params.MIN_DISTANCE;
    end
    if ~isnan(params.MAX_DISTANCE)
        ix = ix & trials.rs <= params.MAX_DISTANCE;
    end
    if params.REMOVE_INCORRECTS
        ix = ix & trials.isCorrect;
    end
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
    if ~isnan(params.END_SHUFFLE)
        ixb = trials.block_index == 2;
        ixt = trials.trial_index > params.END_SHUFFLE;
        trials.block_index(ixb & ixt) = nan;
    end

end
