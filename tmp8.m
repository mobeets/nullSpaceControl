
nms = {'habitual', 'pruning', 'cloud', 'unconstrained'};
hypopts = struct('nBoots', 5, 'obeyBounds', false, ...
    'scoreGrpNm', 'thetaActualGrps16');

lopts = struct('postLoadFcn', @io.splitIntuitiveBlock);
% lopts = struct('postLoadFcn', nan);

popts = struct();
pms = struct();
dts = io.getAllowedDates();
% dts = {'20120327', '20120331', '20131211', '20131212'};

figure(1); hold on;
figure(2); hold on;
 
for ii = [3 2 1]%4:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    save(['data/fits/splitIntuitive/noIme_' dtstr], 'D');
    
    figure(1); subplot(2,3,ii); hold on;
    plot.barByHypQuick(D.score(2:end), 'errOfMeans'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    figure(2); subplot(2,3,ii); hold on;
    plot.errorByKin(D.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');

end

%%

dts = io.getAllowedDates();
dts = [dts {'20120327', '20120331', '20131211', '20131212'}];
% clrs = get(gca, 'ColorOrder');

% S = nan(numel(dts),11);
% SCov = S;
% for ii = 1:numel(dts)
%     dtstr = dts{ii}
%     X = load(['data/fits/savedFull/' dtstr '.mat']); D = X.D;
%     S(ii,:) = [D.score.errOfMeans];
%     SCov(ii,:) = [D.score.covError];
% end
nms = {D.score.name};

inds = ismember(nms, {'habitual', 'cloud', 'unconstrained', 'baseline', 'minimum'});

SC = SCov(:,inds);
nmsC = nms(inds);

[~,ix] = sort(dts);
SC = SC(ix,:);
dtsC = dts(ix);

plot.init;
% for ii = 1:numel(nmsC)
%     plot(1:numel(dts), SC(:,ii), '.-', 'LineWidth', 3, 'MarkerSize', 40);
% end
brs = bar(1:numel(dtsC), SC, 'FaceColor', clrs(1,:));
for ii = 1:numel(brs)
    brs(ii).FaceColor = clrs(ii,:);
end

ixJfy = cellfun(@(c) numel(strfind(c, '2012')) > 0, dtsC);
dtNms = dtsC;
dtNms(ixJfy) = cellfun(@(c) ['J' c], dtNms(ixJfy), 'uni', 0);
dtNms(~ixJfy) = cellfun(@(c) ['L' c], dtNms(~ixJfy), 'uni', 0);

set(gca, 'XTick', 1:numel(dtsC));
set(gca, 'XTickLabel', dtNms);
set(gca, 'XTickLabelRotation', 45);
ylabel('covariance error');
legend(nmsC, 'Location', 'BestOutside');
