
%% init

dtEx = '20120601';
fitNm = 'splitIntuitive';

figs.init;
% figs.createData(fitNm, dts);

[SMu, SCov, D, hypnms, ntrials] = figs.loadData(fitNm, dtEx);

if strcmpi(fitNm, 'splitIntuitive')
    hypSet1 = {'uncontrolled-uniform', 'baseline', 'minimum'};
    hypSet1a = {'baseline', 'minimum'};
    hypSet2 = {'unconstrained', 'baseline-sample', 'minimum-sample'};
    hypSet2a = {'baseline-sample', 'minimum-sample'};
    hypSet3 = {'uncontrolled-uniform', 'baseline', 'minimum', ...
        'unconstrained', 'baseline-sample', 'minimum-sample'};
elseif strcmpi(fitNm, 'savedFull')
    hypSet1 = {'unconstrained', 'baseline', 'minimum'};
    hypSet2 = {'habitual', 'cloud'};
    hypSet3 = {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'};
elseif strcmpi(fitNm, 'allSampling')
    hypSet1 = {'unconstrained', 'baseline-sample', 'minimum-sample'};
    hypSet2 = {'cloud', 'habitual'};
    hypSet3 = {'habitual', 'cloud', 'unconstrained', 'baseline-sample', 'minimum-sample'};
    hypSet4 = {'cloud', 'minimum-sample', 'baseline-sample'};
end

%% tuning curves

curHyps = hypSet1;
% curHyps = hypSet2;
[~, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.tuningCurves(D, curHyps, hypClrs, baseClr);

%% marginal histograms

% close all;
% fopts.doSave = true;
curHyps = ['observed' hypSet1];
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.marginalHistograms(D, hypInds, [45], hypClrs, fopts);
% figs.marginalHistograms(D, hypInds, [], hypClrs, fopts);

%% mean/covariance scatter (for comparing two hyps)

hypSet = hypSet2;
% hypSet = {'minimum-sample', 'baseline-sample'};
% hypSet = {'unconstrained', 'baseline-sample'};
% hypSet = {'cloud', 'baseline-sample'};
% hypSet = {'habitual', 'baseline-sample'};
% ix = Lrn >= 0.7;
ix = true(size(SMu,1),1);

hyp1 = hypSet{1};
hyp2 = hypSet{2};
figs.meanCovScatterTwoHyps(SMu, hypnms, ixMnk, hyp1, hyp2, 'mean', ix);
figs.meanCovScatterTwoHyps(SCov, hypnms, ixMnk, hyp1, hyp2, 'covariance', ix);

%% combining scores across sessions

curHyps = hypSet3;
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
mus = score.normalizeAcrossSessions(SMu(:,hypInds));
cvs = score.normalizeAcrossSessions(SCov(:,hypInds));

lb = 25; ub = 75;
plot.init;
for ii = 1:size(mus,2)    
    plot(mus(:,ii), cvs(:,ii), '.', 'Color', hypClrs(ii,:), ...
        'MarkerSize', 10);
    mups = prctile(mus(:,ii), [lb 50 ub]);
    cvps = prctile(cvs(:,ii), [lb 50 ub]);
    plot([mups(1) mups(3)], [cvps(2) cvps(2)], '-', ...
        'Color', hypClrs(ii,:), 'LineWidth', 2);
    plot([mups(2) mups(2)], [cvps(1) cvps(3)], '-', ...
        'Color', hypClrs(ii,:), 'LineWidth', 2);
    plot(mups(2), cvps(2), '.', 'Color', hypClrs(ii,:), ...
        'MarkerSize', 50);
end
set(gca, 'XTick', 0:0.2:1.0);
set(gca, 'YTick', 0:0.2:1.0);
axis square;

%% EXTRA STUFF BELOW

%% mean/cov err bars

curHyps = hypSet3;
ylims = [nan nan];
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.meanAndCovAllSessions(SMu(:,hypInds), SCov(:,hypInds), ...
    hypClrs, dtnms, hypnms(hypInds), ylims);

%% learning

[Dts, PrtNum, Mnk, PrtType, Lrn, PrfHit] = ...
    io.importPatrickLearningMetrics(dts);

%% mean score vs. # trials in session

curHyps = hypSet3;
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
