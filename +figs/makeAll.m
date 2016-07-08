
%% prefs

dts = io.getAllowedDates();
dts = [dts {'20120327', '20120331', '20131211', '20131212'}];
dts = sort(dts);
% dtEx = '20131125';
dtEx = '20120601';
% dtEx = '20120709';
dtnms = io.addMnkNmToDates(dts);

%% load

% baseDir = fullfile('data', 'fits', 'savedFull'); % Exp. 2
baseDir = fullfile('data', 'fits', 'splitIntuitive'); % Exp. 1
clrs = get(gca, 'ColorOrder');
close;

SMu = cell(numel(dts), 1);
SCov = SMu;
for ii = 1:numel(dts)
    dtstr = dts{ii}
    X = load(fullfile(baseDir, [dtstr '.mat'])); D = X.D;
    SMu{ii} = [D.score.errOfMeans];
    SCov{ii} = [D.score.covError];
end
SMu = cell2mat(SMu);
SCov = cell2mat(SCov);
nms = {D.score.name};

X = load(fullfile(baseDir, [dtEx '.mat'])); D = X.D;

%% 3/5/7

% 3
hypNms = {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'};
maxVal = 5;
curClrs = clrs;

% 5
% hypNms = {'habitual', 'cloud'};
% maxVal = nan;
% curClrs = clrs([4 5],:);

% 7
% hypNms = {'habitual', 'cloud', 'pruning', 'prune + mean shift', 'mean shift'};
% maxVal = nan;
% curClrs = clrs([5 7 4 1 6],:);

% show in reverse
inds = ismember(nms, hypNms);
allInds = 1:numel(D.score);
curInds = allInds(inds);
curInds = curInds(end:-1:1); % uncomment for all but 7

% 3a - mean error for all dts

plot.init;
figs.bar_allDts(SMu(:,curInds), nms(curInds), dtnms, curClrs, 'mean error');

% 3b - cov error for all dts

plot.init;
figs.bar_allDts(SCov(:,curInds), nms(curInds), dtnms, curClrs, 'covariance error');

% 3c 
plot.init;
plot.meanErrorByKinByCol(D, D.score(curInds), false, maxVal);
title('');

%% 4/6 a

% hypNm = 'habitual';
% hypNm = 'cloud';
hypNm = 'baseline';
curHypInd = find(strcmp(nms, hypNm));
hypClr = clrs(curInds == curHypInd,:);
baseClr = [0 0 0];
clr0 = [baseClr; hypClr];

% fig = plot.init;
plot.blkSummaryPredicted(D, D.score(curHypInd), false, false, false, [], clr0);
title('');
figxs = arrayfun(@(ii) fig.Children(ii).Position(1), 1:numel(fig.Children));
[~,ix] = sort(figxs);
arrayfun(@(ii) title(fig.Children(ii), ['mean(YN_' num2str(ix(ii)-1) ')']), ...
    2:numel(fig.Children));

%% 4/5 b

hypNms = {'observed', 'habitual', 'cloud'};
grpVals = [90 180];

hypInds = find(ismember(nms, hypNms));
hypClrs = [baseClr; clrs(curInds == hypInds(2),:); clrs(curInds == hypInds(3),:)];
plot.fitAndPlotMarginals(D, struct('hypInds', hypInds, ...
    'oneKinPerFig', false, 'tightXs', true, 'grpsToShow', grpVals, ...
    'nbins', 50, 'clrs', hypClrs, 'ttl', '', ...
    'sameLimsPerPanel', true, 'doFit', true));
txs = findobj(gcf, 'Type', 'Axes');
for jj = 1:numel(txs)
    txs(jj).FontSize = 14;
    txs(jj).YLim = [0 1];
end

%% load

baseDir = fullfile('data', 'fits', 'randHalfPert');
hypNms = {'habitual', 'cloud'};

S1 = cell(numel(dts),1);
S2 = cell(numel(dts),1);
for ii = 1:numel(dts)
    dtstr = dts{ii}
    X = load(fullfile(baseDir, ['allInt_' dtstr '.mat'])); D = X.D;
    X = load(fullfile(baseDir, ['randHalfPert_' dtstr '.mat'])); D2 = X.D2;
    S1{ii} = [D.score(2:end).errOfMeans];
    S2{ii} = [D2.score(2:end).errOfMeans];
end
S1 = cell2mat(S1);
S2 = cell2mat(S2);
newNms = {D.score.name};
newInds = ismember(newNms, hypNms);

%% 7a

plot.init;
hypNms = {'habitual', 'cloud'};
hypInds = find(ismember(nms, hypNms));
hypClrs = clrs([5 1 4],:);

for hix = newInds
    p = plot(S2(:,hix), '-', 'Color', hypClrs(hix,:), 'LineWidth', 2);
    plot(S1(:,hix), '--', 'Color', p.Color, 'LineWidth', 2);
    plot(S2(:,hix), 'o', 'Color', p.Color, 'MarkerFaceColor', p.Color, ...
        'HandleVisibility', 'off');
    plot(S1(:,hix), 'o', 'Color', p.Color, 'MarkerFaceColor', 'w', ...
        'HandleVisibility', 'off');
end

legend({'habitual, Exp. 1', 'habitual, Exp. 2', ...
    'cloud, Exp. 1', 'cloud, Exp. 2'}, 'Location', 'BestOutside');
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dtnms);
set(gca, 'XTickLabelRotation', 45);
ylabel('mean error');
