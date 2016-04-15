function [vs, bs] = getValuesByTrialByBlock(D, fldNm, grpTrial)
    if nargin < 3
        grpTrial = true;
    end
    vs = [];
    bs = [];
    for ii = 1:numel(D.blocks)
        xc = D.blocks(ii).(fldNm);        
        if grpTrial % each trial gets one value
            ts = D.blocks(ii).trial_index;
            xc = grpstats(xc, ts);
        end
        vs = [vs; xc];
        bs = [bs; ii*ones(numel(xc),1)];
    end
end
