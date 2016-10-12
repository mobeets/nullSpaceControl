%% load ratio of det(cov)

baseDir = 'data/fits/allHypsAgain';
% baseDir = 'data/fits/allHypsNoIme';
% baseDir = 'data/fits/savedFull';
dts = io.getDates();

nboots = 100;

X = load(fullfile(baseDir, [dts{3} '.mat'])); D = X.D;
nms = {D.score.name};
nhyps = numel(nms);

trRatHyps = nan(numel(dts), nhyps);
trRats = nan(numel(dts), nboots);
cvs2 = nan(numel(dts), 2);

fcn = @trace;

for ii = 1:numel(dts)
    
%     D = io.quickLoadByDate(dts{ii});
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    Y2 = B2.latents;    
    
    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    SS0 = (NB2*NB2')*RB1;
    [SSS,s,v] = svd(SS0, 'econ');
    
    cvs2(ii,1) = fcn(cov(Y2*SSS));
    cvs2(ii,2) = fcn(cov(D.hyps(2).latents*SSS));
%     continue;
    
    curFcn = @(Yc, SSS) (fcn(nancov(Yc*SSS))/size(SSS,2)) / ...
        (fcn(nancov(Yc))/size(Yc,2));
    
    if nboots > 1
        tr1 = bootstrp(nboots, @(y) curFcn(y, SSS), Y1);
        tr2 = bootstrp(nboots, @(y) curFcn(y, SSS), Y2);
    else
        tr1 = curFcn(Y1, SSS);
        tr2 = curFcn(Y2, SSS);
    end
    trRats(ii,:) = tr2./tr1;
%     continue;
    
    tr1 = curFcn(Y1, SSS);
    for jj = 1:numel(D.hyps)
        tr2 = curFcn(D.hyps(jj).latents, SSS);
        trRatHyps(ii,jj) = tr2./tr1;
    end    
end

%% bar plot of ratio of det(cov)

dtcv = trRats;
plot.init;
for ii = 1:size(dtcv,1)
    pcs = prctile(dtcv(ii,:), [5 50 95]);
    bar(ii, pcs(2), 'FaceColor', 'w');
    line([ii ii], [pcs(1) pcs(3)], 'Color', 'k');
end
plot(xlim, [1 1], 'k--');
set(gca, 'FontSize', 14);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('trace(cov): irrelevant/relevant');
% ylabel('det(cov): irrelevant');

%% compare hyps - scatters

hyp1 = 'observed';
hyp2 = 'cloud';
hypInd1 = strcmp(nms, hyp1);
hypInd2 = strcmp(nms, hyp2);

plot.init;
for hypInd2 = 2:numel(nms)-3
    v1 = trRatHyps(:,hypInd1);
    v2 = trRatHyps(:,hypInd2);
    corr(v1, v2)
    subplot(2,3,hypInd2-1); hold on;
    plot(v1, v2, 'k.', 'MarkerSize', 10);
    xlim([0 3]);
    ylim([0 3]);
    xlabel('observed trace-cov ime');
    ylabel([nms{hypInd2} ' trace-cov ime']);
    plot(xlim, ylim, 'k--');
    title(nms{hypInd2});
end

%% compare hyps - corrs

curHyps = {'cloud', 'habitual', 'unconstrained', ...
    'uncontrolled-uniform', 'minimum', 'baseline'};
[hinds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);

plot.init;
crs = nan(numel(hinds),1);
for ii = 1:numel(hinds)
    v1 = trRatHyps(:,1);
    v2 = trRatHyps(:,hinds(ii));
    crs(ii) = corr(v1,v2);
    [r,p,rlo,rup] = corrcoef(v1,v2);
    crs(ii) = r(2);
    lb = rlo(2);
    ub = rup(2);
    bar(ii, crs(ii), 'FaceColor', hypClrs(ii,:));
    plot([ii ii], [lb ub], 'k-');
    plot([ii-0.05 ii+0.05], [lb lb], 'k-');
    plot([ii-0.05 ii+0.05], [ub ub], 'k-');
end

set(gca, 'XTick', 1:numel(hinds));
set(gca, 'XTickLabel', nms(hinds));
set(gca, 'XTickLabelRotation', 45);
ylabel('correlation with observed trace-cov ime');
ylim([-0.3 1]);

%% compare trace and det

plot.init;
plot(median(trRats,2), median(trRatsTr,2), 'k.', 'MarkerSize', 15);
xlabel('trace-cov, NoIme');
ylabel('trace-cov, ime');
xlim([0 1.5]);
ylim(xlim);
plot(xlim, ylim, 'k--');
axis square;

%%

plot.init;
plot(Lrn, median(trRats,2), 'k.', 'MarkerSize', 15);
plot(PrfHit, median(trRats,2), 'k.', 'MarkerSize', 15);
