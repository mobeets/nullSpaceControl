function d = filterDataByBlock(d)

trialBlockInds = io.getSuccessfulTrialsByBlock(d);
NBLOCKS = numel(unique(trialBlockInds(~isnan(trialBlockInds))));

spikes = cell(1,NBLOCKS);
r = cell(1,NBLOCKS);
theta = cell(1,NBLOCKS);
extras = cell(1,NBLOCKS);

for blk = 1:NBLOCKS
    idx = trialBlockInds == blk;    
    [spikes{blk}, r{blk}, theta{blk}, extras{blk}] = ...
        io.filterTrialData(d, idx);    
end

d.NBLOCKS = NBLOCKS;
d.spikes = spikes;
d.r = r;
d.theta = theta;
d.extras = extras;

end
