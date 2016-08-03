
%% prefs

dts = io.getDates();
% dts = [dts {'20120327', '20120331', '20131211', '20131212'}];
dts = sort(dts);
dtnms = io.addMnkNmToDates(dts);

clrs = get(gca, 'ColorOrder');
clrs = [clrs; mean(clrs(5:6,:))];
close;

%% create data file

dirNm = 'splitIntuitive'; % Exp. 1
% dirNm = 'savedFull'; % Exp. 2
baseDir = fullfile('data', 'fits', dirNm);

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

fnm = fullfile('data', 'fits', [dirNm '.mat']);
% save(fnm, 'SMu', 'SCov', 'nms');

%% load

% dtEx = '20131125';
dtEx = '20120601';
% dtEx = '20120709';

dirNm = 'splitIntuitive'; % Exp. 1
% dirNm = 'savedFull'; % Exp. 2
Y = load(fullfile('data', 'fits', [dirNm '.mat']));
SMu = Y.SMu; SCov = Y.SCov; nms = Y.nms;
X = load(fullfile('data', 'fits', dirNm, [dtEx '.mat'])); D = X.D;

%% 3/5/7 - mean and cov error

figNum = 3;

switch figNum
    case 3
        hypNms = {'unconstrained', 'baseline', 'minimum'};
        maxVal = 5;
        curClrs = clrs([3 6 5],:);
    case 5
        hypNms = {'habitual', 'cloud'};
        maxVal = nan;
        curClrs = clrs([7 1],:);
    case 7
        hypNms = {'habitual', 'cloud', 'pruning', ...
            'prune + mean shift', 'mean shift'};
        maxVal = nan;
        curClrs = clrs([7 4 1 2 8],:);
end

% show in reverse
inds = ismember(nms, hypNms);
allInds = 1:numel(D.score);
curInds = allInds(inds);
% 
% if figNum == 7
%     curInds = curInds(end:-1:1); % uncomment for all but 7
% end

% 3a - mean error for all dts

plot.init;
figs.bar_allDts(SMu(:,curInds), nms(curInds), dtnms, curClrs, 'mean error');
set(gcf, 'Position', [0 300 1250 200]);

% 3b - cov error for all dts

plot.init;
figs.bar_allDts(SCov(:,curInds), nms(curInds), dtnms, curClrs, 'covariance error');
set(gcf, 'Position', [0 0 1250 200]);

% 3c 
% plot.init;
% plot.meanErrorByKinByCol(D, D.score(curInds), false);%, maxVal);
% title('');

%% 3/5 - tuning curves

curHypNms = hypNms;

% for 7a:
% curInds = [2 3 5 7];
% curHypNms = newNms;
% hypNms = newNms;
% curClrs = clrs([7 2 1 3],:);

fig = plot.init;
for jj = 1:numel(curHypNms)

    curInd = find(strcmp(hypNms, curHypNms{jj}));
    curHypInd = curInds(curInd);
    hypClr = curClrs(curInd,:);
    baseClr = [0 0 0];
    clr0 = [baseClr; hypClr];

    plot.blkSummaryPredicted(D, D.score(curHypInd), false, false, false, [], clr0);
    title('');
    
    if jj == 1
        figxs = arrayfun(@(ii) fig.Children(ii).Position(1), 1:numel(fig.Children));
        [~,ix] = sort(figxs);        
        arrayfun(@(ii) title(fig.Children(ii), ['Y^n(' num2str(ix(ii)-1) ')']), ...
            2:numel(fig.Children));
    end
end
ylabel(fig.Children(ix(2)), 'mean activity');
set(gcf, 'Position', [0 0 1250 160]);

%% 3/5 - histograms

% hypNms = {'observed', 'habitual', 'cloud'};
% curHypNms = {'observed', 'unconstrained', 'baseline', 'minimum'};
curHypNms = [{'observed'} hypNms];
% grpVals = [90 180];
grpVals = [135 270];
% grpVals = [];

hypInds = find(ismember(nms, curHypNms));
hypClrs = nan(numel(curHypNms),3);
hypClrs(1,:) = baseClr;
for ii = 2:numel(curHypNms)
    hypClrs(ii,:) = curClrs(curInds == hypInds(ii),:);
end

plot.fitAndPlotMarginals(D, struct('hypInds', hypInds, ...
    'oneKinPerFig', false, 'tightXs', true, 'grpsToShow', grpVals, ...
    'nbins', 70, 'clrs', hypClrs, 'ttl', '', ...
    'sameLimsPerPanel', true, 'doFit', true, 'makeMax1', true));
txs = findobj(gcf, 'Type', 'Axes');
for jj = 1:numel(txs)
    txs(jj).FontSize = 14;
    txs(jj).YLim = [0 1.2];
end
set(gcf, 'Position', [0 0 1250 numel(grpVals)*160]);

%% create data file

dirNm1 = 'allIntHalfPert_rand';
dirNm2 = 'splitPerturbation_rand';
baseDir1 = fullfile('data', 'fits', dirNm1);
baseDir2 = fullfile('data', 'fits', dirNm2);

S1 = cell(numel(dts),1);
S2 = cell(numel(dts),1);
for ii = 1:numel(dts)
    dtstr = dts{ii}
    X = load(fullfile(baseDir1, [dtstr '.mat'])); D = X.D;
    X = load(fullfile(baseDir2, [dtstr '.mat']));
    if isfield(X, 'D')
        D2 = X.D;
    else
        D2 = X.D2;
    end
    S1{ii} = [D.score(2:end).errOfMeans];
    S2{ii} = [D2.score(2:end).errOfMeans];
end

indsForSome = ismember({D.score(2:end).name}, ...
    {'habitual', 'pruning', 'cloud', 'unconstrained'});
indsSome = cellfun(@numel, S1) == numel(indsForSome);
S1(indsSome) = cellfun(@(c) c(indsForSome), S1(indsSome), 'uni', 0);
S2(indsSome) = cellfun(@(c) c(indsForSome), S2(indsSome), 'uni', 0);

S1 = cell2mat(S1);
S2 = cell2mat(S2);
newNms = {D.score(2:end).name}; newNms = newNms(indsForSome);

fnm = fullfile('data', 'fits', 'splitExps.mat');
save(fnm, 'S1', 'S2', 'newNms');

%% load

fnm = fullfile('data', 'fits', 'splitExps.mat');
Z = load(fnm, 'S1', 'S2', 'newNms');
S1 = Z.S1; S2 = Z.S2; newNms = Z.newNms;

%% 7a

plot.init;
hypNms = {'habitual', 'cloud'};%, 'unconstrained'};
hypInds = find(ismember(newNms, hypNms));
hypClrs = clrs([7 1 1 3],:);

% for ii = 1:size(S1,1)
%     plot([S2(ii,hypInds(1)) S2(ii,hypInds(2))], ...
%         [S1(ii,hypInds(1)) S1(ii,hypInds(2))], ...
%         '-', 'Color', 'k');
%     plot(S2(ii,hypInds(1)), S1(ii,hypInds(1)), 'o', ...
%         'Color', hypClrs(hypInds(1),:), ...
%         'MarkerFaceColor', hypClrs(hypInds(1),:));
%     plot(S2(ii,hypInds(2)), S1(ii,hypInds(2)), 'o', ...
%         'Color', hypClrs(hypInds(2),:), ...
%         'MarkerFaceColor', hypClrs(hypInds(2),:));
% end
% xlabel('Exp. 1 mean error');
% ylabel('Exp. 2 mean error');
% xlim([0 2.5]);
% ylim(xlim);
% plot(xlim, ylim, 'k--');

for hix = hypInds
    
    p = plot(1:numel(dts), (S1(:,hix)-S2(:,hix))./S1(:,hix), '-', ...
        'Color', hypClrs(hix,:), 'LineWidth', 2);
    plot(1:numel(dts), (S1(:,hix)-S2(:,hix))./S1(:,hix), 'o', 'Color', p.Color, ...
        'MarkerFaceColor', 'w', 'HandleVisibility', 'off');
    continue;
    
    p = plot(1:numel(dts), S2(:,hix), '-', 'Color', hypClrs(hix,:), ...
        'LineWidth', 2);
    plot(1:numel(dts), S1(:,hix), '--', 'Color', p.Color, 'LineWidth', 2);
    plot(1:numel(dts),S2(:,hix), 'o', 'Color', p.Color, ...
        'MarkerFaceColor', p.Color, ...
        'HandleVisibility', 'off');
    plot(1:numel(dts),S1(:,hix), 'o', 'Color', p.Color, ...
        'MarkerFaceColor', 'w', 'HandleVisibility', 'off');
end

% legend({'habitual, Exp. 1', 'habitual, Exp. 2', ...
%     'cloud, Exp. 1', 'cloud, Exp. 2', ...
%     'unconstrained, Exp. 1', 'unconstrained, Exp. 2'}, ...
%     'Location', 'BestOutside'});

% legend({'habitual, Exp. 1', 'habitual, Exp. 2', ...
%     'cloud, Exp. 1', 'cloud, Exp. 2'}, ...
%     'Location', 'BestOutside');
ylabel('mean error');

legend({'habitual', 'cloud'}, ...
    'Location', 'BestOutside');
ylabel('% change in mean error');

set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dtnms);
set(gca, 'XTickLabelRotation', 45);
