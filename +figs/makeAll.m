
%% init

% dtEx = '20120601';
dtEx = '20131205';
% fitNm = 'splitIntuitive';
% fitNm = 'savedFull';
% fitNm = 'allHyps';
% fitNm = 'allHypsNoIme';
fitNm = 'allHypsAgain';
% fitNm = 'allHypsEightKins';

figs.init;
% figs.createData(fitNm, dts);

[SMu, SCov, D, hypnms, ntrials, SMuErr, SCovErr] = ...
    figs.loadData(fitNm, dtEx);

if strcmpi(fitNm, 'splitIntuitive')
    hypSet2 = {'uncontrolled-uniform', 'baseline', 'minimum'};
    hypSet2a = {'baseline', 'minimum'};
    hypSet1 = {'unconstrained', 'baseline-sample', 'minimum-sample'};
    hypSet1a = {'baseline-sample', 'minimum-sample'};
    hypSet3 = {'uncontrolled-uniform', 'baseline', 'minimum', ...
        'unconstrained', 'baseline-sample', 'minimum-sample'};
elseif strcmpi(fitNm, 'savedFull')
    hypSet1 = {'unconstrained', 'baseline', 'minimum'};
    hypSet2 = {'habitual', 'cloud'};
    hypSet3 = {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'};
elseif strcmpi(fitNm, 'allSampling') || strcmpi(fitNm, 'allSampling0') ...
        || strcmpi(fitNm, 'allHyps') || strcmpi(fitNm, 'allHypsAgain')
    hypSet1 = {'unconstrained', 'baseline-sample', 'minimum-sample'};
    hypSet2 = {'cloud', 'habitual'};
    hypSet3 = {'habitual', 'cloud', 'unconstrained', 'baseline-sample', 'minimum-sample'};
    hypSet4 = {'habitual', 'cloud', 'uncontrolled-uniform', 'baseline', 'minimum'};
    hypSet5 = {'habitual', 'baseline'};
    hypSet6 = {'habitual', 'cloud', 'unconstrained', 'baseline', 'baseline-sample'};
    hypSet7 = {'habitual', 'cloud', 'baseline', 'minimum'};
    hypSet8 = {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'};
    hypSet9 = {'habitual', 'cloud', 'unconstrained', 'uncontrolled-uniform', 'baseline', 'minimum'};
end

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
fopts.doSave = true;
fopts.showAll = true;
curHyps = ['observed' {'uncontrolled-uniform'}];
% curHyps = {'observed'};
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
% figs.marginalHistograms(D, hypInds, [45], hypClrs, fopts);
figs.marginalHistograms(D, hypInds, [], hypClrs, fopts);

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
figs.meanCovScatterTwoHyps(SMu, hypnms, ixMnk, hyp1, hyp2, 'mean', ix, 2*SMuErr);
figs.meanCovScatterTwoHyps(SCov, hypnms, ixMnk, hyp1, hyp2, 'covariance', ix, 2*SCovErr);

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

%% bar plot across sessions

doAvg = true;
doRank = true;

curHyps = {'cloud', 'habitual', 'unconstrained', 'baseline'};
curHyps = {'cloud', 'habitual', 'unconstrained', ...
    'uncontrolled-uniform', 'minimum', 'baseline'};
% curHyps = hypSet9;

[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
if doRank
    mus = score.sortAcrossSessions(SMu(:,hypInds), 2);
    cvs = score.sortAcrossSessions(SCov(:,hypInds), 2);
    ymx = 7;
    prcs = [25 50 75];
else
    mus = score.normalizeAcrossSessions(SMu(:,hypInds), numel(hypInds));
    cvs = score.normalizeAcrossSessions(SCov(:,hypInds), numel(hypInds));
    ymx = nan;
    prcs = [25 50 75];
end

if doAvg
    
    mups = prctile(mus, prcs);
    ms = mups(2,:); bs = mups([1 3],:);
    plot.init;
    figs.bar_oneDt(ms, hypnms(hypInds), hypClrs, ...
        'error in mean', bs, ymx);
    
    cvps = prctile(cvs, prcs);
    cs = cvps(2,:); bs = cvps([1 3],:);
    plot.init;
    figs.bar_oneDt(cs, hypnms(hypInds), hypClrs, ...
        'error in covariance', bs, ymx);    
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
