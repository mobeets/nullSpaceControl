function B = getDataByBlock(D)

    B = struct([]);
    trialBlockInds = io.getSuccessfulTrialsByBlock(D);
    nblks = numel(unique(trialBlockInds(~isnan(trialBlockInds))));
    for blk = 1:nblks
        idx = trialBlockInds == blk;
        b = struct();
        [b.spikes, b.r, b.theta, b.extras] = ...
            io.filterTrialData(D, idx);
        b.latents = io.convertRawSpikesToRawLatents(...
            D.simpleData, b.spikes);
        B = [B b];
    end

end
