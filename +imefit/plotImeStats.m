function by_trial = plotImeStats(D, bind)

    TAU = 3;
    T_START = TAU + 2;
    TARGET_RADIUS = 20 + 18;
    [U, Y, Xtarget] = imefit.prep(D.blocks(bind));
    [mdlErrs, cErrs, result, by_trial] = imefit.imeErrs(U, Y, Xtarget, ...
        D.ime(bind), TARGET_RADIUS, T_START);
        
    imefit.plotWhiskers(Xtarget, Y, E_P, trialNo, TARGET_RADIUS, T_START);
    
    % scatter of cursor and ime errors
    plot.init; subplot(1,2,1); hold on; set(gca, 'FontSize', 18);
    plot(mdlErrs, cErrs, '.');
    xlabel('internal model error (degrees)');
    ylabel('cursor error (degrees)');
    title([D.datestr ' Blk' num2str(bind)]);
    xlim([0 180]); ylim(xlim);
    set(gca, 'XTick', 0:45:180);
    set(gca, 'YTick', 0:45:180);
    
    % bar plot of average angular errors
    cErrAvg = nanmean(cellfun(@(e) mean(abs(e)), by_trial.cErrs));
    mErrAvg = nanmean(cellfun(@(e) mean(abs(e)), by_trial.mdlErrs));
    subplot(1,2,2); hold on; set(gca, 'FontSize', 18);
    bar(1:2, [cErrAvg, mErrAvg], 'FaceColor', [1 1 1], ...
        'EdgeColor', [0 0 0], 'LineWidth', 1);
    nms = {'cursor', 'ime'};
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    ymx = ceil(max([cErrAvg, mErrAvg]));
    ylim([0 ymx]);
    ytcks = unique(round(get(gca, 'YTick')));
    set(gca, 'YTick', ytcks);
    ylabel('absolute angular error (degrees)');
    title([D.datestr ' Blk' num2str(bind)]);

end
