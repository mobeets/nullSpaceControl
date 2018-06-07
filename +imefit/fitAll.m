
% dts = io.getAllowedDates();
% dts2 = io.getDates();
% dts = dts2(~ismember(dts2, dts));
% dts = io.getDates();
% dts = io.getDates(true, false, {'Nelson'});

% dts = {'20130527', '20131212'};
dts = {'20131205'};

opts = struct('plotdir', 'plots/ime', 'doCv', false, ...
    'doSave', false, 'fitPostLearnOnly', true, 'doLatents', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end

%%

opts.fitPostLearnOnly = false;
[D, Stats, LLs] = imefit.fitSession(dts{20}, opts);
opts.fitPostLearnOnly = true;
[D, Stats, LLs] = imefit.fitSession(dts{20}, opts);

%%

fig = imefit.plotErrByBlock(Stats{1}, Stats{2}); title(D.datestr);
