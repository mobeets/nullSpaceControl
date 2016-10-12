
% dts = io.getAllowedDates();
% dts2 = io.getDates();
% dts = dts2(~ismember(dts2, dts));
% dts = io.getDates();
dts = io.getDates(false, true, {'Nelson'});

opts = struct('plotdir', 'plots/imes', 'doCv', false, ...
    'doSave', false, 'fitPostLearnOnly', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end

%%

opts.fitPostLearnOnly = false;
[D, Stats, LLs] = imefit.fitSession(dts{20}, opts);
opts.fitPostLearnOnly = true;
[D, Stats, LLs] = imefit.fitSession(dts{20}, opts);
