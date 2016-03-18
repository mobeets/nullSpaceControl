
dts = {'20120601', '20120709', '20131212', '20120525'};
params = struct('MAX_ANGULAR_ERROR', 360);
hyps = {'kinematics mean', 'habitual', 'cloud-hab', 'baseline', ...
    'minimum', 'unconstrained', 'volitional-w-2FAs', ...
    'volitional-w-2FAs (s=5)'};
plotOpts = struct('doSolos', true);

% hyps = {'habitual'};
for ii = 1:numel(dts)
    close all;
    dtstr = dts{ii};
    D = fitByDate(dtstr, params, hyps, plotOpts);
end

%%

ps0 = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360);
for ii = 1:numel(dts)
    close all;
    dtstr = dts{ii}
    ps = io.setFilterDefaults(dtstr);
    ps0.END_SHUFFLE = ps.START_SHUFFLE;
    D = fitByDate(dtstr, ps0, hyps, plotOpts);
end
