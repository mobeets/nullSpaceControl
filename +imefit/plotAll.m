
dts = io.getAllowedDates();
opts = struct('plotdir', 'plots/imeCv', 'doCv', true);
for ii = [1 2 3 5] % 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end
