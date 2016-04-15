% 
% 20120525
% 
% learning: 0.823
% performance hit: 6.970

ps = io.setUnfilteredDefaults;
ps.REMOVE_INCORRECTS = false;

dts = io.getAllowedDates;

for ii = 1:numel(dts)
    dtstr = dts{ii};
    D = io.quickLoadByDate(dtstr, ps);
    [lrn, L_bin, L_proj, L_max, L_raw, ls] = behav.learningAllTrials(D);
    [dtstr ' lrn = ' num2str(lrn)]
    figure(1); hold on; plot(L_bin)
    figure(2); hold on; bar(ii, lrn)
end

%%


