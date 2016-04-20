function [B, trials] = getDataByBlock(D)
    
    % load all timepoints and flatten so that each is a trial
    trials = io.filterTrialsByParams(D.trials, D.params);
    trials.angErrorAbs = abs(trials.angError);

    % build struct array grouped by the trial's block
    B = struct([]);
    nblks = max(trials.block_index);
    for ii = 1:nblks
        B = [B io.filterTrialsByIdx(trials, trials.block_index == ii)];
    end

end
