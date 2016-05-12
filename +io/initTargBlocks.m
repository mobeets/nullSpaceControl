function [D, ix1, ix2] = initTargBlocks(D, blkToFit, blk1Pred, blk2Pred)
% initialize a Blk1 to fit data in Blk2, using trials in D.blocks(blkToFit)

    Blk = D.blocks(blkToFit);
    ix1 = blk1Pred(Blk);
    ix2 = blk2Pred(Blk);
    D.blocks(1) = io.filterTrialsByIdx(Blk, ix1);
    D.blocks(2) = io.filterTrialsByIdx(Blk, ix2);
 
end
