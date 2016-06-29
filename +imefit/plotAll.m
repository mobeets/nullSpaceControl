
dts = io.getAllowedDates();
dts2 = io.getDates();
dts = dts2(~ismember(dts2, dts));

dts = {'20120308', '20120327', '20120331', '20131211', '20131212'};

opts = struct('plotdir', 'plots/imeCv', 'doCv', false, 'doSave', true);
opts.plotdir = '';
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end

