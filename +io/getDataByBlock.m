function B = getDataByBlock(D)
    
    % load all timepoints and flatten so that each is a trial
    trials = io.makeTrials(D);
    trials = io.filterTrialsByParams(trials, D.params);

    % build struct array grouped by the trial's block
    B = struct([]);
    nblks = max(trials.block_index);
    for ii = 1:nblks
        B = [B io.filterTrialsByIdx(trials, trials.block_index == ii)];
    end

end
