%% load ratio of det(cov)

baseDir = 'data/fits/allHypsAgain';
dts = io.getDates();

nboots = 100;
nms = {D.score.name};

angsYesIme = nan(numel(dts),1);
angsNoIme = nan(numel(dts),1);
dtcvYesImeNoRot = nan(numel(dts),8,6);
dtcvPert = nan(numel(dts),6,8);
dtcvYesIme = nan(numel(dts),nboots);
dtcvYesIme2 = nan(numel(dts), numel(nms));
dtcvNoIme = nan(numel(dts),1);
for ii = 1:numel(dts)
    
%     D = io.quickLoadByDate(dts{ii});
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    Y2 = B2.latents;
    
    decNm = 'fImeDecoder';
    RB1 = B1.(decNm).RowM2;
    RB2 = B2.(decNm).RowM2;
    angsYesIme(ii) = tools.angleBetweenMappings(RB1, RB2);
    
    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    RB2 = B2.(decNm).RowM2;
    angsNoIme(ii) = tools.angleBetweenMappings(RB1, RB2);
    
    decNm = 'fImeDecoder';
    RB1 = B1.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    SS0 = (NB2*NB2')*RB1;
    
    grps = sort(unique(B2.thetaActualGrps));
    for jj = 1:numel(D.hyps)
        for kk = 1%:numel(grps)
            ig1 = B1.thetaActualGrps >= 0;%grps(kk);
            ig = B2.thetaActualGrps >= 0; grps(kk);
            Y2 = D.hyps(jj).latents(ig,:);
            det1 = trace(cov(Y1(ig1,:)*SS0));
            det2 = trace(cov(Y2*SS0));
            dtcvYesIme2(ii,jj) = det1./det2;
        end
%         dtcvPert(ii,jj) = det2;
    end
    
    continue;
    
    Y1 = B1.latents;
    Y2 = B2.latents;
    [SS,s,v] = svd(SS0, 'econ');
%     [SS,s,v] = svd((RB1*RB1')*NB2, 'econ');
%     SS = SS0*v;
    det1 = det(cov(Y1*SS));
    det2 = det(cov(Y2*SS));

    det1 = bootstrp(nboots, @(x) det(cov(x)), Y1*SS);
    det2 = bootstrp(nboots, @(x) det(cov(x)), Y2*SS);
    dtcvYesIme(ii,:) = det1./det2;
    
    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    SS0 = (NB2*NB2')*RB1;
    [u,s,v] = svd(SS0);
    SS = SS0*v;
    det1 = det(cov(Y1*SS));
    det2 = det(cov(Y2*SS));
    dtcvNoIme(ii) = det1./det2;    

end

%% bar plot of ratio of det(cov)

dtcv = 1./dtcvYesImeNoRot(:,:,1);
dtcv = 1./dtcvYesIme;
plot.init;
% bar(1:numel(dts), dtcv, 'FaceColor', 'w');
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
ylabel('det(cov): irrelevant/relevant');
% ylabel('det(cov): irrelevant');

%% compare ratios with and without IME

plot.init;
plot(1./dtcvNoIme(ixMnk), 1./dtcvYesIme(ixMnk), 'r.', 'MarkerSize', 25);
plot(1./dtcvNoIme(~ixMnk), 1./dtcvYesIme(~ixMnk), 'b.', 'MarkerSize', 25);
xlim([0 2]); ylim(xlim);
plot(xlim, ylim, 'k--');
xlabel('det(cov) no ime');
ylabel('det(cov) with ime');
title('irrelevant / relevant');

%% load learning metrics

[Dts, PrtNum, Mnk, PrtType, Lrn, PrfHit] = io.importPatrickLearningMetrics();
Dts = arrayfun(@num2str, Dts, 'uni', 0);
ixDt = ismember(Dts, dts);
ixMnk = cellfun(@(c) strcmp(c(4), '2'), dts);

%% # trials per dt

ns = nan(numel(dts),2);
for ii = 1:numel(dts)
%     D = io.quickLoadByDate(dts{ii});
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    ns(ii,1) = numel(D.blocks(1).time);
    ns(ii,2) = numel(D.blocks(2).time);
end

%%

plot.init;
% xs = ns(:,2);
% ys = SMu(:,5);
xs = Lrn(ixDt);
ys = SCov(:,5) - SCov(:,2);

% subplot(2,2,4); hold on;
plot(xs(ixMnk), ys(ixMnk), '.', 'MarkerSize', 25);
plot(xs(~ixMnk), ys(~ixMnk), '.', 'MarkerSize', 25);


%% compare learning to ratio of det(cov)

xs = Lrn(ixDt);
ys = 1./dtcvYesImeNoRot;
% ys = 1./dtcvYesIme;

plot.init;
plot(xs(ixMnk), ys(ixMnk), 'r.', 'MarkerSize', 25);
plot(xs(~ixMnk), ys(~ixMnk), 'b.', 'MarkerSize', 25);
xlabel('learning');
ylabel('det(cov), no ime');

%% compare dtcvYesImeNoRot by grp, ALL HYPS

ys = 1./dtcvYesImeNoRot;
plot.init;
c = 0;
nms = {D.score.name};
for jj = [2 4 5]
    c = c + 1;
    subplot(1,3,c); hold on;
    x1 = squeeze(ys(:,:,1));
    x2 = squeeze(ys(:,:,jj));
    plot(x1, x2, 'k.');
    ylabel(nms{jj});
    mn = min([x1(:); x2(:)]);
    mx = max([x1(:); x2(:)]);
    mn = 0; mx = 5;
        
    axis equal;
    xlim([mn mx]);
    ylim([mn mx]);
    plot(xlim, ylim, 'k--');
    
end

%% compare learning to ratio of det(cov), ALL HYPS

xs = Lrn(ixDt);
ys = 1./dtcvYesImeNoRot;
% ys = dtcvPert;

plot.init;
for jj = 1:size(ys,2)
    subplot(2,3,jj); hold on;
    plot(xs(ixMnk), ys(ixMnk,jj), 'r.', 'MarkerSize', 25);
    plot(xs(~ixMnk), ys(~ixMnk,jj), 'b.', 'MarkerSize', 25);
    xlabel('learning');
    ylabel('det(cov), no ime');
    title(nms{jj});
end

%% compare learning to angle between mappings

xs = PrfHit(ixDt);
ys = angsNoIme;

plot.init;
plot(xs(ixMnk), ys(ixMnk), 'r.', 'MarkerSize', 25);
plot(xs(~ixMnk), ys(~ixMnk), 'b.', 'MarkerSize', 25);
xlabel('learning');
ylabel('angle between mappings, no ime');
