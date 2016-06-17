
dts = io.getAllowedDates();
opts = struct('plotdir', 'plots/imeCv', 'doCv', true);
opts.plotdir = '';
for ii = 1%1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end
