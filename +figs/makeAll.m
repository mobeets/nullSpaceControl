
%% prefs

dts = io.getAllowedDates();
dts = [dts {'20120327', '20120331', '20131211', '20131212'}];
dts = sort(dts);
dtEx = '20131125';

hypNms = {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'};

baseDir = fullfile('data', 'fits', 'savedFull');

%% load

dtnms = io.addMnkNmToDates(dts);
clrs = get(gca, 'ColorOrder');
close;

SMu = cell(numel(dts), 1);
SCov = SMu;
SMuSq = SMu;
for ii = 1:numel(dts)
    dtstr = dts{ii}
    X = load(fullfile(baseDir, [dtstr '.mat'])); D = X.D;
    SMu{ii} = [D.score.errOfMeans];
    SCov{ii} = [D.score.covError];
    SMuSq{ii} = {D.score.errOfMeansByKinByCol};
end
SMu = cell2mat(SMu);
SCov = cell2mat(SCov);
nms = {D.score.name};

inds = ismember(nms, hypNms);

X = load(fullfile(baseDir, [dtEx '.mat'])); D = X.D;

%% 3

% 3a - mean error for all dts

plot.init;
figs.bar_allDts(SMu(:,inds), nms(inds), dtnms, clrs, 'mean error');

% 3b - cov error for all dts

plot.init;
figs.bar_allDts(SCov(:,inds), nms(inds), dtnms, clrs, 'covariance error');

% 3c 
plot.init;
plot.meanErrorByKinByCol(D, D.score(inds), false, 5);
