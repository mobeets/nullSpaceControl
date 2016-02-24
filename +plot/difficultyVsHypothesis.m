%% find habitual and volitional errors per kinematics for all dates

dts = {'20120525', '20120601', '20131125', '20131205'};

ysHab = cell(numel(dts),1);
ysVol = cell(numel(dts),1);
dfs = cell(numel(dts),1);

for ii = 1:numel(dts)
    dtstr = dts{ii};
    D = io.loadDataByDate(dtstr);
    D.params = io.setFilterDefaults(D.params);
    D.params.MAX_ANGULAR_ERROR = 360;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    D = tools.rotateLatentsUpdateDecoders(D, false);
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    D.hyps = pred.addPrediction(D, 'volitional + 2PCs', ...
        pred.volContFit(D, true, 2));

    B = D.blocks(2);
    ths = B.thetas;
    Y1 = B.latents;
    Y2 = D.hyps(2).latents;
    Y3 = D.hyps(3).latents;
    [ysHab{ii}, cnts] = plot.valsByKinematics(D, ths, Y1, Y2, 8, true, 2);
    [ysVol{ii}, cnts] = plot.valsByKinematics(D, ths, Y1, Y3, 8, true, 2);

    dfs{ii} = D.simpleData.shufflePerformance.target;
end

ysHab = cell2mat(ysHab);
ysVol = cell2mat(ysVol);

%% organize difficulty metrics to match shape of hypothesis errors

fns = fieldnames(dfs{1}.initialDifficulty);
nfns = numel(fns);
ratsInit = cell(nfns,1);
for ii = 1:numel(fns)
   ratsInit{ii} = cell2mat(cellfun(@(d) d.initialDifficulty.(fns{ii}), ...
        dfs, 'uni', 0)')'; 
end
ratsEnd = cell(nfns,1);
for ii = 1:numel(fns)
   ratsEnd{ii} = cell2mat(cellfun(@(d) d.lateDifficulty.(fns{ii}), dfs, ...
        'uni', 0)')'; 
end

ratsDiff = arrayfun(@(ii) ratsEnd{ii} - ratsInit{ii}, ...
    1:numel(ratsInit), 'uni', 0)';

%% compare a hypothesis with a difficulty metric

xs0 = ysVol;
vs0 = ratsInit;
xnm = 'volitional';
ynm = 'initDiff';
clrByDt = true;

nm = [xnm ' - ' ynm];
dtnms = dts;
knnms = arrayfun(@(x) num2str(x), cnts, 'uni', 0);
[ndts, nkins] = size(xs0);
clrs1 = cbrewer('qual', 'Set2', ndts);
clrs2 = cbrewer('div', 'RdYlGn', nkins);

if ~clrByDt
    xs = xs0';
    vs = cellfun(@(v) v', vs0, 'uni', 0);
    nms = knnms;
    clrs = clrs2;
else
    xs = xs0;
    vs = vs0;
    nms = dtnms;
    clrs = clrs1;
end

fig = figure; hold on; set(gcf, 'color', 'w');

for ii = 1:numel(vs)
    subplot(numel(vs), 1, ii); hold on; box off; 
    set(gca, 'FontSize', 14);
    xlabel([xnm ' error']);
    ylabel(fns{ii});
    if ii == 1
        title(nm);
    end
    v = vs{ii};
    for jj = 1:size(xs,1)
        [xv, ix] = sort(xs(jj,:));
        yv = v(jj,:); yv = yv(ix);
        plot(xv, yv, '-', 'Color', clrs(jj,:), 'LineWidth', 3);
        plot(xv, yv, 'o', 'Color', clrs(jj,:), ...
            'MarkerFaceColor', clrs(jj,:), 'HandleVisibility', 'off');
    end
    legend(nms, 'Location', 'BestOutside');
end

set(fig, 'Position', [100, 100, 400, 600]);
fig.PaperPositionMode = 'auto';
print(fullfile('plots', 'diffVsError', nm), '-dpng', '-r0');
