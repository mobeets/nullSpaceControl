
% dts = io.getAllowedDates();
% dts2 = io.getDates();
% dts = dts2(~ismember(dts2, dts));
dts = io.getDates();

opts = struct('plotdir', 'plots/imes', 'doCv', false, 'doSave', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end
