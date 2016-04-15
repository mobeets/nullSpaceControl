function [vs, bs] = getValuesByTrialByBlock(D, fldNm)
    vs = [];
    bs = [];
    for ii = 1:numel(D.blocks)
        xc = D.blocks(ii).(fldNm);
        ts = D.blocks(ii).trial_index;
        xc = grpstats(xc, ts); % each trial should have same value
        vs = [vs; xc];
        bs = [bs; ii*ones(numel(xc),1)];
    end
end
