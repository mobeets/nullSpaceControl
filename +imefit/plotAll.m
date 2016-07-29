
dts = io.getAllowedDates();
dts2 = io.getDates();
dts = dts2(~ismember(dts2, dts));
% dts = {'20120303', '20120319', '20131218'};

opts = struct('plotdir', 'plots/imeCv', 'doCv', false, 'doSave', true);
opts.plotdir = '';
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end
