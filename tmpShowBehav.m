
% fit opts
opts = struct();
opts.muThresh = 0.5;
opts.varThresh = 0.5;
opts.trialsInARow = 100;
opts.groupEvalFcn = @numel; % longest group of consecutive trials
opts.minGroupSize = 100; % want at least 150 consecutive trials
opts.meanBinSz = 100; % smoothing for mean
opts.varMeanBinSz = 100; % smoothing for mean before var
opts.varBinSz = 100; % bin size for running var
opts.behavNm = 'trial_length'; % 'progress'

behNm = 'acquisition time (normalized)';
lw = 3;

for ii = 1:numel(dts)
    % load data; get trial length
    dtstr = dts{ii};
    D = io.loadData(dtstr, false, false);
    B = D.blocks(2);
    xs = B.trial_index;
    ys = grpstats(xs, xs, @numel);
    xs = unique(xs);
    
    [isGood, ixs, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts);
    trialsToKeep = xsb(ixs{1});
    isGood = all(isGood);
    
end
