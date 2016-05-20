function [BlkFirst, BlkLast] = trialIndsSplit(Blk)
    trs = Blk.trial_index;
    ts = sort(unique(trs));
    trHalf = round(min(ts) + range(ts)/2);
    
    ixFirst = trs <= trHalf;
    BlkFirst = io.filterTrialsByIdx(Blk, ixFirst);
    BlkLast = io.filterTrialsByIdx(Blk, ~ixFirst);
end
