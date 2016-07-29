
dts = io.getAllowedDates();
dts = io.getDates();
baseDir = 'data/fits/savedFull';

% det1 = nan(numel(dts),1);
% det2 = nan(numel(dts),1);
% eig1 = nan(numel(dts),8);
% eig2 = nan(numel(dts),8);
% 
% nboots = 1000;
% dt1 = nan(numel(dts),nboots);
% dt2 = nan(numel(dts),nboots);
% angs = nan(numel(dts),1);
mscs = nan(numel(dts),11);
cscs = nan(numel(dts),11);

for ii = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    dts{ii}
    
    mscs(ii,:) = [D.score.errOfMeans];
    cscs(ii,:) = [D.score.covError];
    continue;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.fDecoder.NulM2;
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
    
    angs(ii,:) = tools.angleBetweenMappings(RB1, RB2);

    Y2 = D.blocks(2).latents;
%     Y = Y*NB2;
%     [u,s,v] = svd(Y);
    v = (NB2*NB2')*RB1;
    v = NB2;
    Y2 = Y2*v;
%     Y2 = Y2(:,1:2);
    
    Y1 = D.blocks(1).latents;
    Y1 = Y1*v;
    
    ll = 0;
    sz = 15;
    lw = 3;    
    
    Yc = Y2;
    Yd = Y1;
    
    det1(ii,:) = det(cov(Y1));
    det2(ii,:) = det(cov(Y2));
    eig1(ii,:) = eig(cov(Y1));
    eig2(ii,:) = eig(cov(Y2));
    dt1(ii,:) = bootstrp(nboots, @(y) det(cov(y)), Y1);
    dt2(ii,:) = bootstrp(nboots, @(y) det(cov(y)), Y2);
    continue;
        
    [bp, mu] = tools.gauss2dcirc(Yc, 0.5);
    [bp2, mu2] = tools.gauss2dcirc(Yd, 0.5);
    clr1 = [0.2 0.2 0.8];
    clr2 = [0.8 0.2 0.2];
    
    plot.init;
    plot([mu(1) mu2(1)], [mu(2) mu2(2)], '-', 'LineWidth', lw, ...
        'Color', clr1, 'MarkerSize', sz);
    plot(mu(1), mu(2), 'ko', 'MarkerFaceColor', clr1, 'MarkerSize', sz);
    plot(mu2(1), mu2(2), 'ks', 'MarkerFaceColor', clr2, 'MarkerSize', sz);
    plot(bp(1,:), bp(2,:), '-', 'Color', clr1);
    plot(bp2(1,:), bp2(2,:), '--', 'Color', clr2);


    plot.subtitle([D.datestr ' in NB2'], 'FontSize', 20);

end

%%

fsz = 12;
plot.init;
nrows = 3; ncols = 1;
subplot(nrows,ncols,2); hold on;
for ii = 1:numel(dts)
    cd = dt1(ii,:);
    bs = prctile(cd, [5 95]);
    bar(ii, mean(cd), 'FaceColor', 'w');
    plot([ii ii], bs, 'k-');
end
set(gca, 'FontSize', fsz);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('det(cov): relevant');
subplot(nrows,ncols,3); hold on;
for ii = 1:numel(dts)
    cd = dt2(ii,:);
    bs = prctile(cd, [5 95]);
    bar(ii, mean(cd), 'FaceColor', 'w');
    plot([ii ii], bs, 'k-');
end
set(gca, 'FontSize', fsz);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('det(cov): irrelevant');
subplot(nrows,ncols,1); hold on;
for ii = 1:numel(dts)
    cd = dt2(ii,:)./dt1(ii,:);
    bs = prctile(cd, [5 95]);
    bar(ii, mean(cd), 'FaceColor', 'w');
    plot([ii ii], bs, 'k-');
end
plot(xlim, [1 1], 'k--');
set(gca, 'FontSize', fsz);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('det(cov): irrelevant/relevant');

%%

plot.init;
for ii = 1:numel(dts)
    cd = dt2(ii,:)./dt1(ii,:);
    bs = prctile(cd, [5 95]);
    bar(ii, mean(cd), 'FaceColor', 'w');
    plot([ii ii], bs, 'k-');
end
plot(xlim, [1 1], 'k--');
set(gca, 'FontSize', fsz);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('det(cov): irrelevant/relevant');

%%
plot.init;
boxplot(dt2'./dt1', 'sym', 'k.');
p = prctile(dt2'./dt1',[5 95]);
plot(xlim, [1 1], 'k--');
set(gca, 'FontSize', fsz);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('det(cov): irrelevant/relevant');
box off;

%%

plot.init;
hist(mean(dt2'./dt1'), 10);

%%

% Replace upper end y value of whisker
h = flipud(findobj(gca,'Tag','Upper Whisker'));
for j=1:length(h);
    ydata = get(h(j),'YData');
    ydata(2) = p(2,j);
    set(h(j),'YData',ydata);
end

% Replace all y values of adjacent value
h = flipud(findobj(gca,'Tag','Upper Adjacent Value'));
for j=1:length(h);
    ydata = get(h(j),'YData');
    ydata(:) = p(2,j);
    set(h(j),'YData',ydata);
end

% Replace lower end y value of whisker
h = flipud(findobj(gca,'Tag','Lower Whisker'));
for j=1:length(h);
    ydata = get(h(j),'YData');
    ydata(1) = p(1,j);
    set(h(j),'YData',ydata);
end

% Replace all y values of adjacent value
h = flipud(findobj(gca,'Tag','Lower Adjacent Value'));
for j=1:length(h);
    ydata = get(h(j),'YData');
    ydata(:) = p(1,j);
    set(h(j),'YData',ydata);
end


%%

plot.init;
rt = mean(dt2,2)./mean(dt1,2);
rt = log(rt);
% rt = abs(rt);
% xs = angs;
xs = cscs;
ys = rt;
% ys = rt;
plot(xs, ys, 'ko');
% plot(angs, mean(dt1,2), 'bo');
% plot(angs, mean(dt2,2), 'ro');
% xlim([0 90]);
% set(gca, 'XTick', 10:10:90);
xlabel('cloud mean error');
% xlabel('largest principle angle between mappings');
ylabel('log(det(cov(irr)) / det(cov(rel)))');
ylabel('abs(log(det(cov(irr)) / det(cov(rel))))');

%%

plot.init;
plot(eig1(:,1), eig1(:,2), 'wo', 'MarkerFaceColor', clr1);
plot(eig2(:,1), eig2(:,2), 'wo', 'MarkerFaceColor', clr2);

%%

dts = io.getAllowedDates();
baseDir = 'data/fits/savedFull';

for ii = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.fDecoder.NulM2;
    RB1 = B1.fDecoder.RowM2;

    gs = B2.thetaActualGrps;
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    nms = {D.hyps.name};
    hix = ismember(nms, {'habitual', 'cloud', 'unconstrained'});
    inds = 1:numel(D.hyps);
    hinds = inds(hix);    
    
    Y2 = D.hyps(1).latents;
%     Y = Y*NB2;
%     [u,s,v] = svd(Y);
    v = (NB2*NB2')*RB1;
    Y2 = Y2*v; Y2 = Y2(:,1:2);
    
    ll = 0;
    sz = 15;
    lw = 3;
    plot.init;
    for jj = hinds
        Y1 = D.hyps(jj).latents;
        Y1 = Y1*v;
%         Yh = (Yh*NB2)*v; Yh = Yh(:,1:2);

        ll = ll + 1;
        subplot(1,numel(hinds),ll); hold on;
        set(gca, 'FontSize', 20);
        
        for mm = 1:numel(grps)
            ig = gs == grps(mm);
            Yc = Y2(ig,:);
            Yd = Y1(ig,:);
            [bp, mu] = tools.gauss2dcirc(Yc, 0.5);
            [bp2, mu2] = tools.gauss2dcirc(Yd, 0.5);
            clr1 = clrs(mm,:); clr2 = clr1;
            plot([mu(1) mu2(1)], [mu(2) mu2(2)], '-', 'LineWidth', lw, ...
                'Color', clr1, 'MarkerSize', sz);
            plot(mu(1), mu(2), 'ko', 'MarkerFaceColor', clr1, 'MarkerSize', sz);
            plot(mu2(1), mu2(2), 'ws', 'MarkerFaceColor', clr2, 'MarkerSize', sz);
            plot(bp(1,:), bp(2,:), '-', 'Color', clr1);
            plot(bp2(1,:), bp2(2,:), '--', 'Color', clr2);
            
        end
        xlabel(D.hyps(jj).name);
    end
    plot.subtitle([D.datestr ' in NB2'], 'FontSize', 20);

end

%%



dts = io.getAllowedDates();
baseDir = 'data/fits/savedFull';

for ii = 3%1:numel(dts)
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB1 = B1.fDecoder.NulM2;
    NB2 = B2.fDecoder.NulM2;
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;

    grpNm = 'thetaActualGrps';
    grpNm = 'targetAngle';
    gs = B2.(grpNm);
    gs2 = B1.(grpNm);    
    
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    nms = {D.hyps.name};
    hix = ismember(nms, {'habitual', 'cloud', 'unconstrained'});
    inds = 1:numel(D.hyps);
    hinds = inds(hix);    
    
    Y2 = D.hyps(1).latents;
%     Y = Y*NB2;
%     [u,s,v] = svd(Y);
    v = (NB2*NB2')*RB1;
%     v = (NB2*NB2')*NB1(:,1:2);
    Y2 = Y2*v; Y2 = Y2(:,1:2);
    
    Y1 = D.blocks(1).latents;
    Y1 = Y1*v;    
    
%     gs2 = score.thetaGroup(tools.computeAngles(D.blocks(1).latents*RB2), score.thetaCenters);
%     gs = score.thetaGroup(tools.computeAngles(D.blocks(2).latents*RB2), score.thetaCenters);
    
    ll = 0;
    sz = 15;
    lw = 3;
    plot.init;
    set(gcf, 'color', 'k');
    for jj = 1%hinds
%         Yh = D.hyps(jj).latents;
%         Yh = Yh*v;
%         Yh = (Yh*NB2)*v; Yh = Yh(:,1:2);

        ll = ll + 1;
        hold on;
        set(gca, 'FontSize', 20);
        
        for mm = 1:numel(grps)
            subplot(3,3,mm); hold on;
            set(gca, 'color', 'k');
            ig = gs == grps(mm);
            ig2 = gs2 == grps(mm);
            Yc = Y2(ig,:);
            Yd = Y1(ig2,:);
            clr1 = clrs(mm,:); clr2 = clr1;
            plot(Yc(:,1), Yc(:,2), '.', 'Color', 0.3*ones(3,1));
            plot(Yd(:,1), Yd(:,2), '.', 'Color', 0.7*ones(3,1));
            [bp, mu] = tools.gauss2dcirc(Yc, 2);
            [bp2, mu2] = tools.gauss2dcirc(Yd, 2);
            plot([mu(1) mu2(1)], [mu(2) mu2(2)], '-', 'LineWidth', lw, ...
                'Color', clr1, 'MarkerSize', sz);
            plot(mu(1), mu(2), 'ko', 'MarkerFaceColor', clr1, 'MarkerSize', sz);
            plot(mu2(1), mu2(2), 'ws', 'MarkerFaceColor', clr2, 'MarkerSize', sz);
            plot(bp(1,:), bp(2,:), '-', 'Color', clr1, 'LineWidth', lw);
            plot(bp2(1,:), bp2(2,:), '--', 'Color', clr2, 'LineWidth', lw);
            plot(0, 0, 'x', 'Color', [0.8 0.2 0.2], 'MarkerSize', 15, 'LineWidth', lw);
            
        end
        xlabel(D.hyps(jj).name);
    end
    plot.subtitle([D.datestr ' in NB2'], 'FontSize', 20);

end

%%

mu = [0 0];
sig = [1 0; 0 1];
X = mvnrnd(mu+2, sig, 1000);
Y = mvnrnd(mu, sig, 1000);

% n = 1000;
% X = zeros(n, 2);
% X(:,2) = normrnd(0,1,n,1);
% X(:,1) = rand(n,1)/100;

clr1 = [0.2 0.2 0.5];
clr2 = [0.5 0.5 0.5];
% clr = [0.8 0.2 0.2];
% clr = [0.2 0.8 0.2];

close all;
plot.init;
plot(X(:,1), X(:,2), '.', 'Color', clr1);
plot(Y(:,1), Y(:,2), '.', 'Color', clr2);
axis off;

%%

B = D.blocks(2);
vs = B.vel;
vs = B.latents*D.blocks(2).fDecoder.RowM2;
gs = B.targetAngle;
grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));
plot.init;
for ii = 1:numel(grps)
    ig = grps(ii) == gs;
    plot(vs(ig,1), vs(ig,2), '.', 'Color', clrs(ii,:));
end
for ii = 1:numel(grps)
    ig = grps(ii) == gs;
    plot(mean(vs(ig,1)), mean(vs(ig,2)), 'ko', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 15);
end


%%

errsA = cell(numel(dts),1);
errsB = cell(numel(dts),1);
for jj = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{jj} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);

    NB1 = B1.fDecoder.NulM2;
    NB2 = B2.fDecoder.NulM2;
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
    Y1 = B1.latents;
    Y2 = B2.latents;

    grpNm = 'targetAngle';
    grpNm = 'thetaGrps';
    grpNm = 'thetaActualGrps';
    gs1 = B1.(grpNm);
    gs2 = B2.(grpNm);
    grps = sort(unique(gs));

    ZhA = nan(size(Y2));
    ZhB = nan(size(Y2));
    for ii = 1:numel(grps)
        ig1 = grps(ii) == gs1;
        ig2 = grps(ii) == gs2;

        ZA = Y1(ig1,:);
        ZB = Y1;
        Z2 = Y2(ig2,:);

        ds = pdist2(Z2*RB2, ZA*RB2);
        [~, inds] = min(ds, [], 2);
        ZhA(ig2,:) = ZA(inds,:);

        ds = pdist2(Z2*RB2, ZB*RB2);
        [~, inds] = min(ds, [], 2);
        ZhB(ig2,:) = ZB(inds,:);
    end
    errsA{jj} = score.quickScore(Y2, ZhA, gs2);
    errsB{jj} = score.quickScore(Y2, ZhB, gs2);

end

%%

plot.init;
for jj = 1:numel(dts)
    subplot(2,3,jj); hold on;
    plot(grps, errsA{jj});
    plot(grps, errsB{jj});
end

%%


errsA = cell(numel(dts),1);
errsB = cell(numel(dts),1);
for jj = 1%:numel(dts)
%     X = load(fullfile(baseDir, [dts{jj} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);

    NB1 = B1.fDecoder.NulM2;
    NB2 = B2.fDecoder.NulM2;
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
    Bs = [RB2 NB2];
    Y1 = B1.latents;
    Y2 = B2.latents;

    grpNm = 'targetAngle';
    gs1 = B1.(grpNm);
    gs2 = B2.(grpNm);
    grps = sort(unique(gs));

    ZhA = nan(size(Y2));
    ZhB = nan(size(Y2));
    vs1 = nan(numel(grps),2);
    vs2 = nan(numel(grps),2);
    for ii = 1:numel(grps)
        ig1 = grps(ii) == gs1;
        ig2 = grps(ii) == gs2;

        ZA = Y1(ig1,:);
        Z2 = Y2(ig2,:);
        
        v1 = var(ZA*Bs);
        v2 = var(Z2*Bs);
        vs1(ii,:) = [mean(v1(1:2)) mean(v1(3:end))];
        vs2(ii,:) = [mean(v2(1:2)) mean(v2(3:end))];
    end

    plot.init;
%     nrows = 1; ncols = 3;
%     subplot(nrows, ncols, 1); hold on;
    plot(vs1(:,1), 'k');
    plot(vs1(:,2), 'k--');
    plot(vs2(:,1), 'r');
    plot(vs2(:,2), 'r--');
    
end

%%

% D = io.quickLoadByDate('20120709', struct('MIN_DISTANCE', nan, 'MAX_DISTANCE', nan));
B = D.blocks(1);
trs = sort(unique(B.trial_index));
plot.init;
for ii = 1:numel(trs)
    ix = B.trial_index == trs(ii);
    if unique(B.targetAngle(ix)) ~= 0
        continue;
    end
    ps = B.pos(ix,:);    
    plot(ps(1,1), ps(1,2), 'ko');
    plot(ps(:,1), ps(:,2), '-');
    plot(ps(end,1), ps(end,2), 'k+');
    plot(ps(end-1,1), ps(end-1,2), 'ks');
end

%%

