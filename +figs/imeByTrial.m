
doSave = true;
saveDir = 'plots';
wd = 5; ht = 5; mrg = 0.125;
clr1 = 'k';
clr2 = 'k';
lw = 3;
binSz = 50;

dtstr = '20131205';
d = load(['data/ime/' dtstr '.mat']);

close all;
plot.init;

for ii = 2%1:2
    B = d.Stats{ii};
    xs = B.trial_inds;
    inds = 2:(numel(xs)-1);
    
    Ys = B.by_trial.cErrs;
    ys = cellfun(@(e) nanmean(abs(e)), Ys);
    ys = smooth(ys, binSz);
    plot(xs(inds), ys(inds), '-', 'Color', clr1, 'LineWidth', lw);
    
    Ys = B.by_trial.mdlErrs;
    ys = cellfun(@(e) nanmean(abs(e)), Ys);
    ys = smooth(ys, binSz);
    plot(xs(inds), ys(inds), '--', 'Color', clr2, 'LineWidth', lw);
end

xlabel('Trial #');
ylabel('Angular cursor error (deg)');
% yl = ylim; ylim([0 max(yl)]);
set(gca, 'TickDir', 'out');
set(gca, 'Ticklength', [0 0]);

figs.setPrintSize(gcf, wd, ht, mrg);
if doSave
    export_fig(gcf, fullfile(saveDir, 'imeByTrial.pdf'));
end

%% bar plot avg over trials

doSave = false;
saveDir = 'plots';
wd = 5; ht = 7; mrg = 0.125;
opts = struct('width', 5, 'height', 4, 'margin', 0.125);
fsz = 20;
lw = 2;

dts = {'20131205'};
vs = nan(numel(dts),4);

for ii = 1:numel(dts)
    dtstr = dts{ii};
    d = load(['data/ime/' dtstr '.mat']);

    % intuitive stats
    by_trial = d.Stats{1}.by_trial;
    scale = 1.96/sqrt(numel(by_trial.cErrs));
    iErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    iErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    jErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    jErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    
    % perturbation stats
    by_trial = d.Stats{2}.by_trial;
    scale = 1.96/sqrt(numel(by_trial.cErrs));
    cErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    cErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));

    vs(ii,:) = [iErrAvg jErrAvg cErrAvg mErrAvg];
    
    plot.init;
    xts = [1 3 5 7];
    bar(xts, [iErrAvg jErrAvg cErrAvg, mErrAvg], 'FaceColor', [1 1 1], ...
        'EdgeColor', [0 0 0], 'LineWidth', lw);
    plot([xts(1) xts(1)], [iErrAvg-iErrStd iErrAvg+iErrStd], 'k-');
    plot([xts(2) xts(2)], [jErrAvg-jErrStd jErrAvg+jErrStd], 'k-');
    plot([xts(3) xts(3)], [cErrAvg-cErrStd cErrAvg+cErrStd], 'k-');
    plot([xts(4) xts(4)], [mErrAvg-mErrStd mErrAvg+mErrStd], 'k-');
    nms = {'1st mapping', '1st mapping (IM)', ...
        '2nd mapping', '2nd mapping (IM)'};
    set(gca, 'XTickLabel', nms, 'XTick', xts, 'XTickLabelRotation', 45);
    ymx = ceil(max([cErrAvg+cErrStd, mErrAvg+mErrStd]));
    ymx = 10;
    ylim([0 ymx]);
%     ytcks = unique(round(get(gca, 'YTick')));
    ytcks = 0:5:ymx;
    set(gca, 'YTick', ytcks);
    ylabel('Abs. angular cursor error (deg)');
    axis square;
    set(gca, 'FontSize', fsz);
    set(gca, 'TickDir', 'out');
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', lw);

    figs.setPrintSize(gcf, opts);
    if doSave
        export_fig(gcf, fullfile(saveDir, 'imeAvgPerf.pdf'));
    else
        export_fig(gcf, 'plots/tmp.pdf');
    end
end

%% pct return to baseline levels, avg over sessions

doSave = true;
saveDir = fopts.plotdir;
wd = 5; ht = 5; mrg = 0.125;
fsz = 24;

cErrDelta = (vs(:,2)-vs(:,1))./vs(:,1);
mErrDelta = (vs(:,3)-vs(:,1))./vs(:,1);
mus = -[mean(cErrDelta) mean(mErrDelta)];
scale = 2/sqrt(numel(cErrDelta));
sds = scale*[std(cErrDelta) std(mErrDelta)];

plot.init;
bar(1:2, mus, 'FaceColor', [1 1 1], ...
        'EdgeColor', [0 0 0], 'LineWidth', 1);
plot([1 1], [mus(1)-sds(1) mus(1)+sds(1)], 'k-');
plot([2 2], [mus(2)-sds(2) mus(2)+sds(2)], 'k-');
nms = {'Pert.', 'Pert. (IME)'};
set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
ylabel('Change from intuitive performance (%)');
axis square;
set(gca, 'FontSize', fsz);
set(gca, 'TickDir', 'out');
set(gca, 'Ticklength', [0 0]);
    
figs.setPrintSize(gcf, wd, ht, mrg);
if doSave
    export_fig(gcf, fullfile(saveDir, 'imeAvgDev.pdf'));
else
    export_fig(gcf, 'plots/tmp.pdf');
end
