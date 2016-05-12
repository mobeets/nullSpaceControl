
dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = io.quickLoadByDate(dtstr, io.setUnfilteredDefaults);
    b1 = imefit.plotImeStats(D, 1);
%     saveas(gcf, fullfile('plots', 'ime', [dtstr '_1.png']));
    b2 = imefit.plotImeStats(D, 2);
%     saveas(gcf, fullfile('plots', 'ime', [dtstr '_2.png']));

    imefit.plotErrByBlock(b1, b2); title(dtstr);
    saveas(gcf, fullfile('plots', 'ime', [dtstr '_byTrial.png']));

    bind = 1;
    trialNo = 2;
	imefit.plotWhiskers(D, bind, trialNo);
end
