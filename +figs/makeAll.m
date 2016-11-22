
%% init

% dtEx = '20120601';
dtEx = '20131205';
% fitNm = 'splitIntuitive';
% fitNm = 'savedFull';
% fitNm = 'allHyps';
% fitNm = 'allHypsNoIme';
fitNm = 'allHypsAgain';
% fitNm = 'allAutoFit';
% fitNm = 'allHypsEightKins';

figs.init;
% figs.createData(fitNm, dts);

[SMu, SCov, D, hypnms, ntrials, ntimes, SMuErr, SCovErr, dts] = ...
    figs.loadData(fitNm, dtEx, dts);

%% tuning curves

curHyps = hypSet2;
curHyps = {'uncontrolled-uniform'};
curHyps = {'cloud'};
hypnms = {D.score.name};
fopts.doSave = false;
[~, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.tuningCurves(D, curHyps, hypClrs, baseClr, fopts);

%% marginal histograms

% close all;
hypnms = {D.score.name};
fopts.doSave = false;
fopts.showAll = true;
popts = struct('FontName', 'Times', 'FontSize', 12, ...
    'margin', 0, 'LineWidth', 1, 'yMax', 0.6);

dimInds = 1:3; popts.width = 5;

% fopts.plotdir = 'notes/cosyne/imgs';
% fopts.ext = 'pdf';
% postfix = '_cosyne';
% grpVals = [90]; popts.height = 1.5;

fopts.plotdir = 'notes/sfn/imgs';
fopts.ext = 'pdf';
popts.FontName = 'Helvetica';
postfix = '';
popts.LineWidth = 3;
popts.FontSize = 16;
grpVals = score.thetaCenters(4); popts.height = 10;

nms = {'minimum', 'baseline', 'uncontrolled-uniform', 'unconstrained', ...
    'habitual', 'cloud'};
% nms = {'unconstrained'};
for ii = 1:numel(nms)
    curHyps = ['observed' nms(ii)];    
    [hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, ...
        allHypClrs);
    fopts.nameFcn = @(jj) ['margHist-' nms{ii} postfix];
    figs.marginalHistograms(D, hypInds, grpVals, hypClrs, dimInds, ...
        fopts, popts);
end

%% mean/covariance scatter (for comparing two hyps)

% hypSet = hypSet2;
hypSet = {'habitual', 'cloud'};
% hypSet = {'unconstrained', 'cloud'};
% hypSet = {'cloud-200', 'habitual'};
% hypSet = {'baseline', 'unconstrained'};
% hypSet = {'minimum-sample', 'baseline-sample'};
% hypSet = {'unconstrained', 'baseline-sample'};
% hypSet = {'cloud', 'baseline-sample'};
% hypSet = {'habitual', 'baseline-sample'};
% ix = Lrn >= 0.7;
ix = true(size(SMu,1),1);

hyp1 = hypSet{1};
hyp2 = hypSet{2};
figs.meanCovScatterTwoHyps(SMu, hypnms, ixMnk == 1, hyp1, hyp2, 'mean', ix, 2*SMuErr);
figs.meanCovScatterTwoHyps(SCov, hypnms, ixMnk == 1, hyp1, hyp2, 'covariance', ix, 2*SCovErr);

%% rank-order across sessions

curHyps = {'cloud', 'habitual', 'unconstrained', 'baseline', ...
    'minimum', 'uncontrolled-uniform'};
% curHyps = hypSet9;
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);

rnkMu = score.sortAcrossSessions(SMu(:,hypInds), 2);
rnkCv = score.sortAcrossSessions(SCov(:,hypInds), 2);
mx = numel(hypInds);

% add jitter
rnkMuJ = rnkMu + (rand(size(rnkMu))-0.5)/3;
rnkCvJ = rnkCv + (rand(size(rnkCv))-0.5)/3;

plot.init;
for ii = 1:mx
    plot(rnkMuJ(:,ii), rnkCvJ(:,ii), '.', 'Color', hypClrs(ii,:), ...
        'MarkerSize', 10);
end
for ii = 1:mx
    plot(mean(rnkMu(:,ii)), mean(rnkMu(:,ii)), '.', ...
        'Color', hypClrs(ii,:), 'MarkerSize', 50);
end

xlim([0 mx+1]);
ylim([0 mx+1]);
set(gca, 'XTick', 1:mx);
set(gca, 'YTick', 1:mx);
axis square;
xlabel('rank in mean error');
ylabel('rank in covariance error');

%% combining scores across sessions

curHyps = {'cloud', 'habitual', 'unconstrained', 'baseline'};
curHyps = {'cloud', 'habitual', 'unconstrained', 'uncontrolled-uniform', ...
    'minimum', 'baseline'};
% curHyps = hypSet9;
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
mus = score.normalizeAcrossSessions(SMu(:,hypInds), numel(hypInds));
cvs = score.normalizeAcrossSessions(SCov(:,hypInds), numel(hypInds));

% lb = 25; ub = 75;
lb = 50; ub = 50;
plot.init;
for ii = 1:size(mus,2)
    plot(mus(:,ii), cvs(:,ii), '.', 'Color', hypClrs(ii,:), ...
        'MarkerSize', 10);
    mups = prctile(mus(:,ii), [lb 50 ub]);
    cvps = prctile(cvs(:,ii), [lb 50 ub]);
    plot([mups(1) mups(3)], [cvps(2) cvps(2)], '-', ...
        'Color', hypClrs(ii,:), 'LineWidth', 3);
    plot([mups(2) mups(2)], [cvps(1) cvps(3)], '-', ...
        'Color', hypClrs(ii,:), 'LineWidth', 3);
    plot(mups(2), cvps(2), '.', 'Color', hypClrs(ii,:), ...
        'MarkerSize', 50);
end
% set(gca, 'XScale', 'log');
% set(gca, 'YScale', 'log');
xmx = 1*max(median(mus));
ymx = 1*max(median(cvs));
xlim([0 xmx]);
ylim([0 ymx]);
set(gca, 'XTick', 0:1:8);
set(gca, 'YTick', 0:1:8);
axis square;
xlabel('error in mean (normalized)');
ylabel('error in covariance (normalized)');

%% bar plot across sessions (rank or normalized)

doSave = false;
doAvg = true;
doRank = false;
showPts = false;
% saveDir = fopts.plotdir;

saveDir = 'notes/cosyne/imgs';
postfix = '_cosyne';
nmsShown = hypNmsShown_cosyne;
FontSize = 24;
FontName = 'Times';
wd = 6; ht = 3; mrg = 0.125; % in inches
curHyps = {'minimum', 'baseline', 'uncontrolled-uniform', ...
    'unconstrained', 'cloud'};

close all;

% saveDir = 'notes/sfn/imgs';
% postfix = '-rnk_sfn';
% nmsShown = hypNmsShown;
% FontSize = 24;
% FontName = 'Helvetica';
% wd = 6; ht = 6; mrg = 0.125; % in inches
% curHyps = {'minimum', 'baseline', 'uncontrolled-uniform', ...
%     'unconstrained', 'habitual', 'cloud'};

[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
if doRank
    mus = score.sortAcrossSessions(SMu(:,hypInds), 2);
    cvs = score.sortAcrossSessions(SCov(:,hypInds), 2);
    ymx = numel(curHyps);
    prcs = [25 50 75];
    ylbl = 'Rank order';
else
    mus = score.normalizeAcrossSessions(SMu(:,hypInds), nan);
    cvs = score.normalizeAcrossSessions(SCov(:,hypInds), nan);
    mus = SMu(:,hypInds);
    cvs = SCov(:,hypInds);
    ymx = nan;
    prcs = [25 50 75];
    ylbl = 'Avg. error across sessions';% (normalized)';
end
mups = prctile(mus, prcs);
cvps = prctile(cvs, prcs);

mue = 2*std(mus)/sqrt(size(mus,1));
cve = 2*std(cvs)/sqrt(size(cvs,1));

if ~showPts
    mus = [];
    cvs = [];
end

if doAvg
    nmsToShow = figs.getHypDisplayNames(hypnms(hypInds), ...
        hypNmsInternal, nmsShown);
    
    ms = mups(2,:); bs = mups([1 3],:);
%     bs = [];
    bs = [ms - mue; ms + mue];
    plot.init(FontSize, FontName);
%     for ii = 1:numel(hypInds)
%         bar(ii, sum(mus(:,ii)==1), 'FaceColor', hypClrs(ii,:), 'EdgeColor', hypClrs(ii,:));
%     end
    figs.bar_oneDt(ms, nmsToShow, hypClrs, ...
        ylbl, bs, ymx, mus);
%     set(gca, 'YTick', 5:5:size(mus,1)); set(gca, 'YTickLabel', 5:5:size(mus,1)); ylim([0 size(mus,1)]);
    figs.setPrintSize(gcf, wd, ht, mrg);
    title('Error in mean');
    if doSave
        export_fig(gcf, fullfile(saveDir, ['bar_rankMean' postfix '.pdf']));
    end
        
    cs = cvps(2,:); bs = cvps([1 3],:);
%     bs = [];
    bs = [cs - cve; cs + cve];
    plot.init(FontSize, FontName);
%     for ii = 1:numel(hypInds)
%         bar(ii, sum(cvs(:,ii)==1), 'FaceColor', hypClrs(ii,:), 'EdgeColor', hypClrs(ii,:));
%     end
    figs.bar_oneDt(cs, nmsToShow, hypClrs, ...
        ylbl, bs, ymx, cvs);
%     ylim([0 200]);
%     set(gca, 'YTick', 5:5:size(mus,1)); set(gca, 'YTickLabel', 5:5:size(mus,1)); ylim([0 size(mus,1)]);
    figs.setPrintSize(gcf, wd, ht, mrg);
    title('Error in covariance');
    if doSave
        export_fig(gcf, fullfile(saveDir, ['bar_rankCov' postfix '.pdf']));
    end
else
    figs.meanAndCovAllSessions(mus, cvs, ...
        hypClrs, dtnms, hypnms(hypInds), [4 2]);
end

%% EXTRA STUFF BELOW

%% mean/cov err bars

curHyps = hypSet9;
ylims = [nan nan];
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.meanAndCovAllSessions(SMu(:,hypInds), SCov(:,hypInds), ...
    hypClrs, dtnms, hypnms(hypInds), ylims);

%% learning

[Dts, PrtNum, Mnk, PrtType, Lrn, PrfHit] = ...
    io.importPatrickLearningMetrics(dts);

%% mean score vs. # trials in session

curHyps = hypSet9;
hypInds = figs.getHypIndsAndClrs(curHyps, hypnms);
% xs = ntrials(:,1); xlbl = '# trials in intuitive session';
xs = Lrn; xlbl = 'Learning';
% xs = PrfHit; xlbl = 'Performance hit';

plot.init;
for ii = 1:numel(hypInds)
    subplot(1, numel(hypInds), ii); hold on;
    ys = SMu(:, hypInds(ii));
    plot(xs(ixMnk), ys(ixMnk), '.', 'MarkerSize', 20);
    plot(xs(~ixMnk), ys(~ixMnk), '.', 'MarkerSize', 20);
    if ii == 1
        xlabel(xlbl);
        ylabel('mean error');
    end
    title(curHyps{ii});
end
