
%% init

figs.init;
% figs.createData('allSampling', dts);
[SMu, SCov, D, hypnms] = figs.loadData('savedFull', '20120601');
hypSet1 = {'unconstrained', 'baseline', 'minimum'};
hypSet2 = {'habitual', 'cloud'};
hypSet3 = {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'};

[SMu, SCov, D, hypnms] = figs.loadData('allSampling', '20120525');
hypSet1 = {'unconstrained', 'baseline-sample', 'minimum-sample'};
hypSet2 = {'habitual', 'cloud'};
hypSet3 = {'habitual', 'cloud', 'unconstrained', 'baseline-sample', 'minimum-sample'};
hypSet4 = {'cloud', 'baseline-sample'};
hypSet5 = {'minimum-sample', 'baseline-sample'};

%% tuning curves

curHyps = hypSet5;
% curHyps = hypSet2;
[~, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.tuningCurves(D, curHyps, hypClrs, baseClr);

%% marginal histograms

curHyps = ['observed' hypSet1];
% curHyps = ['observed' hypSet2];
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
% figs.marginalHistograms(D, hypInds, [270], hypClrs);
figs.marginalHistograms(D, hypInds, [], hypClrs);

%% mean/covariance scatter (for comparing two hyps)

hyp1 = hypSet5{1};
hyp2 = hypSet5{2};
figs.meanCovScatterTwoHyps(SMu, SCov, hypnms, hyp1, hyp2, 'mean');
figs.meanCovScatterTwoHyps(SMu, SCov, hypnms, hyp1, hyp2, 'covariance');

%% mean/cov err bars

curHyps = hypSet3;
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
figs.meanAndCovAllSessions(SMu(:,hypInds), SCov(:,hypInds), ...
    hypClrs, dtnms, hypnms(hypInds));
