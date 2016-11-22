
% dts = io.getAllowedDates();
% dts2 = io.getDates();
% dts = dts2(~ismember(dts2, dts));
dts = io.getDates();
% dts = io.getDates(true, false, {'Nelson'});

opts = struct('plotdir', 'plots/ime', 'doCv', false, ...
    'doSave', true, 'fitPostLearnOnly', true);
for ii = 28:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end

%%

opts.fitPostLearnOnly = false;
[D, Stats, LLs] = imefit.fitSession(dts{20}, opts);
opts.fitPostLearnOnly = true;
[D, Stats, LLs] = imefit.fitSession(dts{20}, opts);
