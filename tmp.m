
%%

D = io.loadRawDataByDate('20130528');
% E = io.loadRawDataByDate('20120709');

%%

for ii = 25:numel(dts)
    dts{ii}
    io.saveDataByDate(dts{ii});
end

%%

[Dts, PrtNum, Mnk, PrtType, Lrn, PrfHit] = io.importPatrickLearningMetrics();
Dts = arrayfun(@num2str, Dts, 'uni', 0);
dts = io.getDates();
ix = ismember(Dts, dts);

%%

ix1 = strcmp(PrtType, 'within-manifold') & PrtNum == 1;
dtsNew = Dts(~ix & ix1)

%%

ys = Lrn(ix);
ys = PrfHit(ix);
plot.init;
bar(1:numel(dts), ys, 'FaceColor', 'w');
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', Dts(ix));
set(gca, 'XTickLabelRotation', 45);

%%

xs = Lrn(ix);
% xs = yrng(:,1) - yrng(:,4);
% xs = Lrns;
% xs = PrfHits;
% xs = PrfHit(ix);
% xs = yrng(:,3);
[~,ixc] = sort(xs);

hinds = [2 5 7 8];
plot.init;
for ii = hinds
    h = plot(xs(ixc), mscs(ixc,ii), '.-', 'MarkerSize', 25);
    mdl = fitlm(xs, mscs(:,ii));
    plot(xs, mdl.predict(xs), '-', 'Color', h.Color, 'HandleVisibility', 'off');
end
xlabel('Learning (Patrick)');
ylabel('mean error');
legend({'habitual', 'cloud', 'unconstrained', 'baseline'});

%%

% yrng(ii,1,jj) = nanmin(Ys{ii,jj});
% yrng(ii,2,jj) = nanmax(Ys{ii,jj});
% yrng(ii,3,jj) = yrng(ii,2) - yrng(ii,1);
% yrng(ii,4,jj) = nanmean(Ys{ii,jj});
% yrng(ii,5,jj) = Ys{ii,jj}(1);

hind = 5;
plot.init;
for ii = 1:size(Mscs,1)
    xs2 = squeeze(yrng(ii,4,:));
    xs1 = squeeze(yrng(ii,5,:));
    xs = xs1-xs2;
    ys = squeeze(Mscs(ii,hind,:));
    [~,ixc] = sort(xs);
    h = plot(xs(ixc), ys(ixc), '.', 'MarkerSize', 25);
    mdl = fitlm(xs, ys);
    plot(xs, mdl.predict(xs), '-', 'Color', h.Color);
end
xlabel('Learning (Patrick)');
ylabel('mean error');

%%

plot.init;
mnk1 = cellfun(@(c) strcmp(c(4), '2'), dts);
xs = Lrn(ix);
% xs = Lrn(ix).*PrfHit(ix);
% xs = ns(:,2);%ns(:,1);
ys = mscs(:,2);
plot(xs(mnk1), ys(mnk1), 'b.', 'MarkerSize', 25);
plot(xs(~mnk1), ys(~mnk1), 'r.', 'MarkerSize', 25);
xlabel('learning');
ylabel('habitual mean err');
% plot(ns(:,1), mscs(:,5), '.', 'MarkerSize', 25);

%%

xnm = 'trial_index';
ynm = 'isCorrect';
% ynm = 'trial_length';
grpNm = 'targetAngle';
ps = struct('REMOVE_INCORRECTS', false, 'START_SHUFFLE', nan);
Xs = cell(numel(dts),8);
Ys = Xs;
for ii = 1:numel(dts)
    D = io.quickLoadByDate(dts{ii}, ps);
    xss = D.blocks(2).(xnm);
    yss = D.blocks(2).(ynm);
    if ~isempty(grpNm)
        gs = D.blocks(2).(grpNm);
        grps = sort(unique(gs));
    else
        gs = ones(size(xss));
        grps = 1;
    end
    plot.init; 
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        [xs, ys] = behav.smoothAndBinVals(xss(ix), yss(ix));
        plot(xs, ys);
        Xs{ii,jj} = xs; Ys{ii,jj} = ys;
    end
    xlabel(xnm); ylabel(ynm); title(dts{ii});
    saveas(gcf, 'plots/tmp.png');
end

%%

yrng = nan(numel(dts),5,8);
for ii = 1:numel(dts)
    for jj = 1:8
        yrng(ii,1,jj) = nanmin(Ys{ii,jj});
        yrng(ii,2,jj) = nanmax(Ys{ii,jj});
        yrng(ii,3,jj) = yrng(ii,2) - yrng(ii,1);
        yrng(ii,4,jj) = nanmean(Ys{ii,jj});
        yrng(ii,5,jj) = Ys{ii,jj}(1);
    end
end

%%

LrnMe = nan(numel(dts),1);
PrfHitMe = nan(numel(dts),1);
for ii = 1:numel(dts)
    dts{ii}
    [LrnMe(ii),PrfHitMe(ii)] = behav.patrickLearning(dts{ii});
end

%%

plot.init; plot(Lrn(ix), Lrns, 'o');
plot.init; plot(PrfHit(ix), PrfHits, 'o');

%%

%%

plot.init;
errs = cell(10,1);
for p = 1:10
    Y1 = D.blocks(1).latents;
    Y2 = D.blocks(2).latents;
    RB2 = D.blocks(2).fDecoder.RowM2;
    R2 = Y2*RB2;
    [u,s,v] = svd(Y1, 'econ');
    A = v(:,1:p);
    % Y1h = u(:,1:p)*s(1:p,1:p)*A';
    % mean(sqrt(sum((Y1h - Y1).^2,2)))


    M = RB2'*A;
    z2 = M\R2';
    Z2 = (A*z2)';

    ds = pdist2(Z2, Y1);
    [~, inds] = min(ds, [], 2);
    Z = Y1(inds,:);

    NB2 = D.blocks(2).fDecoder.NulM2;
    gs = D.blocks(2).thetaActualGrps;
    errs{p} = score.quickScore(Y2*NB2, Z*NB2, gs);
    plot(errs{p});
end

plot(score.quickScore(Y2*NB2, D.score(5).latents*NB2, gs), '--');
plot(score.quickScore(Y2*NB2, D.score(2).latents*NB2, gs), '--');

%%

plot.init;
colind = 1;
hinds = [2 5 7 8 9];


% clrs = [0 0 0; clrs];
for jj = 1:numel(hinds)
    H = D.hyps(hinds(jj));
    for ii = 1:16
        Y = H.nullActivity.zNullBin{ii};
        subplot(4,4,ii); hold on;
        
%         v = mean(Y(:,colind));
%         plot([v v], [jj-0.5 jj+0.5], '-', 'LineWidth', 3, 'Color', clrs(jj,:));
%         continue;
        
        for kk = 1:8
            v = mean(Y(:,kk));
            plot([v v], [kk-0.5 kk+0.5], '-', 'LineWidth', 3, 'Color', clrs(jj,:));
        end
    end
end

%%

for ii = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    Y1 = D.blocks(1).latents;
    Y2 = D.blocks(2).latents;
    RB1 = D.blocks(1).fDecoder.RowM2;
    RB2 = D.blocks(2).fDecoder.RowM2;
    NB1 = D.blocks(1).fDecoder.NulM2;
    NB2 = D.blocks(2).fDecoder.NulM2;
    
    Bss = {RB1, RB2, NB1, NB2};
    vs = nan(numel(Bss),1);
    for jj = 1:numel(Bss)
        Bs = Bss{jj};
        p = 1;
        [u,s,v] = svd(Y1*Bs, 'econ');
        [u2,s2,v2] = svd(Y2*Bs, 'econ');
        vs(jj) = tools.angleBetweenMappings(v(:,1:p), v2(:,1:p));
    end
    dts{ii}
    vs
end

%%

Y1 = D.blocks(1).latents;
Y2 = D.blocks(2).latents;
RB1 = D.blocks(1).fDecoder.RowM2;
RB2 = D.blocks(2).fDecoder.RowM2;
NB1 = D.blocks(1).fDecoder.NulM2;
NB2 = D.blocks(2).fDecoder.NulM2;

gs1 = D.blocks(1).thetaActualGrps;
gs2 = D.blocks(2).thetaActualGrps;
grps = sort(unique(grps));
clrs = cbrewer('div', 'RdYlGn', numel(grps));

Bs1 = (RB1*RB1')*NB2;
Bs2 = (NB2*NB2')*RB1;
Y1a = Y1*Bs1;
Y2a = Y2*Bs1;
Y1b = Y1*Bs2;
Y2b = Y2*Bs2;

[u,s,v] = svd(Y1a);
[u2,s2,v2] = svd(Y2a);
tools.angleBetweenMappings(v(:,1:2), v2(:,1:2))
V = v(:,1:2);
Y1a = Y1a*V;
Y2a = Y2a*V;

%%

lm = tools.getLims([Y1b(:); Y2b(:)]);
plot.init;
subplot(2,2,1); hold on;
vs = Y1b; gs = gs1;
for ii = 1:numel(grps)
    clr = clrs(ii,:);
    ix = gs == grps(ii);
    plot(vs(ix,1), vs(ix,2), '.', 'Color', clr);
end
% plot(Y1b(:,1), Y1b(:,2), '.');
xlim(lm); ylim(lm); axis equal;
subplot(2,2,2); hold on;
% plot(Y2b(:,1), Y2b(:,2), '.');
vs = Y2b; gs = gs2;
for ii = 1:numel(grps)
    clr = clrs(ii,:);
    ix = gs == grps(ii);
    plot(vs(ix,1), vs(ix,2), '.', 'Color', clr);
end
xlim(lm); ylim(lm); axis equal;

lm = tools.getLims([Y1a(:); Y2a(:)]);
subplot(2,2,3); hold on;
% plot(Y1a(:,1), Y1a(:,2), '.');
vs = Y1a; gs = gs1;
for ii = 1:numel(grps)
    clr = clrs(ii,:);
    ix = gs == grps(ii);
    plot(vs(ix,1), vs(ix,2), '.', 'Color', clr);
end
xlim(lm); ylim(lm); axis equal;
subplot(2,2,4); hold on;
% plot(Y2a(:,1), Y2a(:,2), '.');
vs = Y2a; gs = gs2;
for ii = 1:numel(grps)
    clr = clrs(ii,:);
    ix = gs == grps(ii);
    plot(vs(ix,1), vs(ix,2), '.', 'Color', clr);
end
xlim(lm); ylim(lm); axis equal;



%%

% dts = io.getAllowedDates();
dts = io.getDates();
baseDir = 'data/fits/savedFull';
angs = nan(numel(dts),8);
for ii = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
%     B3 = B1; B1 = B2; B2 = B1;
    
    Y1 = B1.latents;
    Y2 = B2.latents;
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
    NB1 = B1.fDecoder.NulM2;
    NB2 = B2.fDecoder.NulM2;
    
    plot.init;
    Bss = [NB1 RB1];
    mus = nan(size(Bss,2),2);
    vrs = nan(size(Bss,2),2);
    for jj = 1:size(Bss,2)
        Bs = (NB2*NB2')*Bss(:,jj);
        Yc1 = Y1*Bs;
        Yc2 = Y2*Bs;
        mus(jj,1) = mean(Yc1);
        mus(jj,2) = mean(Yc2);
        vrs(jj,1) = var(Yc1);
        vrs(jj,2) = var(Yc2);
        subplot(3,4,jj); hold on;
        lm = tools.getLims([Yc1; Yc2]);
        bins = linspace(lm(1), lm(2), 50);
        [b1,cs1] = hist(Yc1,bins);
        [b2,cs2] = hist(Yc2,bins);
        plot(bins, -b1./trapz(b1,cs1), 'Color', [0.8 0.2 0.2], 'LineWidth', 2);
        plot(bins, -b2./trapz(b2,cs2), 'Color', [0.2 0.2 0.8]);
        if jj <= size(NB1,2)
            title(['NB1(' num2str(jj) ')']);
        else
            title(['RB1(' num2str(jj-size(NB1,2)) ')']);
        end
        if jj == 1
            ylabel('Y in NB2');
        end
    end
    subplot(3,4,jj+1); hold on;
    nNull = size(NB1,2);
    nRow = size(RB1,2);
    bar(1:nNull, abs(diff(mus(1:nNull,:),[],2)), ...
        'EdgeColor', 'k', 'FaceColor', 'w');
    bar(nNull+1:nNull+nRow, abs(diff(mus(nNull+1:end,:),[],2)), ...
        'EdgeColor', 'w', 'FaceColor', 'k');
    title('abs(mean change)');
    xlim([0 jj+1]);
    
    subplot(3,4,jj+2); hold on;
    bar(1:nNull, abs(diff(mus(1:nNull,:)./vrs(1:nNull,:),[],2)), ...
        'EdgeColor', 'k', 'FaceColor', 'w');
    bar(nNull+1:nNull+nRow, abs(diff(mus(nNull+1:end,:)./vrs(nNull+1:end,:),[],2)), ...
        'EdgeColor', 'w', 'FaceColor', 'k');
    title('abs(mean change)./var');
    xlim([0 jj+1]);
    
    plot.subtitle(D.datestr);
    fnm = 'plots/tmp.png';
%     fnm = ['plots/newIrrelevantVsAlwaysIrrelevant/hists/' dts{ii} '.png'];
    saveas(gcf, fnm);
    
    continue;

%     Bs1 = (RB1*RB1')*NB2;
    Bs1 = (NB2*NB2')*NB1(:,1:2);
    Bs2 = (NB2*NB2')*RB1;    
    
    Y1a = Y1*Bs1;
    Y2a = Y2*Bs1;
    Y1b = Y1*Bs2;
    Y2b = Y2*Bs2;
    
    YR1 = Y1*RB1;
    YR2 = Y2*RB1;

%     [u,s,v] = svd(Y1a);
%     [u2,s2,v2] = svd(Y2a);
%     tools.angleBetweenMappings(v(:,1:2), v2(:,1:2))
%     V = v(:,1:2);
%     Y1a = Y1a*V;
%     Y2a = Y2a*V;
%     
%     [A,B,R,U,V,stats]=canoncorr(YR1, Y1a);
%     stats
%     continue;

%     [u,s,v] = svd(Y1b);
%     [u2,s2,v2] = svd(Y2b);
%     aB = tools.angleBetweenMappings(v(:,1), v2(:,1));
%     [u,s,v3] = svd(Y1a);
%     [u2,s2,v4] = svd(Y2a);
%     aA = tools.angleBetweenMappings(v3(:,1), v4(:,1));
%     {dts{ii} aA aB}
%     continue;

    lm = tools.getLims([Y1b(:); Y2b(:)]);
    plot.init;
    ncols = 2; nrows = 2;

    subplot(nrows,ncols,1); hold on;
    plot(Y1b(:,1), Y1b(:,2), '.');
    xlim(lm); ylim(lm); axis equal;
    title('YN1 in RB1');

    subplot(nrows,ncols,2); hold on;
    plot(Y2b(:,1), Y2b(:,2), '.');
    xlim(lm); ylim(lm); axis equal;
    title('YN2 in RB1');

    lm = tools.getLims([Y1a(:); Y2a(:)]);
    subplot(nrows,ncols,3); hold on;
    plot(Y1a(:,1), Y1a(:,2), '.');
    xlim(lm); ylim(lm); axis equal;
    title('YN1 in NB1,1:2');

    subplot(nrows,ncols,4); hold on;
    plot(Y2a(:,1), Y2a(:,2), '.');
    xlim(lm); ylim(lm); axis equal;
    title('YN2 in NB1,1:2');
%     
%     lm = tools.getLims([YR1(:); YR2(:)]);
%     subplot(nrows,ncols,5); hold on;
%     plot(YR1(:,1), YR1(:,2), '.');
%     xlim(lm); ylim(lm); axis equal;
%     title('YR1');
%     
%     subplot(nrows,ncols,6); hold on;
%     plot(YR2(:,1), YR2(:,2), '.');
%     xlim(lm); ylim(lm); axis equal;
%     title('YR2');
    
    plot.subtitle(dts{ii});
    fnm = ['plots/newIrrelevantVsAlwaysIrrelevant/dist/' dts{ii} '.png'];
%     fnm = 'plots/tmp.png';
    saveas(gcf, fnm);
end

%%

dts = io.getAllowedDates();
% dts = io.getDates();
baseDir = 'data/fits/savedFull';

for ii = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
%     B3 = B1; B1 = B2; B2 = B1;
    
    Y1 = B1.latents;
    Y2 = B2.latents;
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
    NB1 = B1.fDecoder.NulM2;
    NB2 = B2.fDecoder.NulM2;
    
    Bs1 = (NB2*NB2')*NB1(:,1:2);
    Bs2 = (NB2*NB2')*RB1;
    
    Y1a = Y1*Bs1;
    Y2a = Y2*Bs1;
    Y1b = Y1*Bs2;
    Y2b = Y2*Bs2;
    
    plot.init;
%     ncols = 2; nrows = 2;
    ncols = 2; nrows = 1;
    
    Yc = Y1b;
    Yd = Y2b;
    lm = tools.getLims([Yc(:); Yd(:)]);
    [bp, mu] = tools.gauss2dcirc(Yc, 2);
    [bp2, mu2] = tools.gauss2dcirc(Yd, 2);
    clr1 = [0.8 0.2 0.2];
    clr2 = [0.2 0.2 0.8];
    clr1p = clr1; clr1p(clr1p==0.2) = 0.5;
    clr2p = clr2; clr2p(clr2p==0.2) = 0.5;
    subplot(nrows,ncols,1); hold on;
    plot(Yd(:,1), Yd(:,2), '.', 'Color', clr2p);
    plot(Yc(:,1), Yc(:,2), '.', 'Color', clr1p);    
    plot(mu(1), mu(2), 'ko', 'MarkerFaceColor', clr1);
    plot(bp(1,:), bp(2,:), '-', 'Color', clr1, 'LineWidth', 2);
    plot(mu2(1), mu2(2), 'ko', 'MarkerFaceColor', clr2);
    plot(bp2(1,:), bp2(2,:), '-', 'Color', clr2, 'LineWidth', 2);
%     xlim(lm); ylim(lm);
    axis equal;
    title('YN1 and YN2 in RB1');
    
    Yc = Y1a;
    Yd = Y2a;
    lm = tools.getLims([Yc(:); Yd(:)]);
    [bp, mu] = tools.gauss2dcirc(Yc, 2);
    [bp2, mu2] = tools.gauss2dcirc(Yd, 2);
    clr1 = [0.8 0.2 0.2];
    clr2 = [0.2 0.2 0.8];
    clr1p = clr1; clr1p(clr1p==0.2) = 0.5;
    clr2p = clr2; clr2p(clr2p==0.2) = 0.5;
    subplot(nrows,ncols,2); hold on;
    plot(Yd(:,1), Yd(:,2), '.', 'Color', clr2p);
    plot(Yc(:,1), Yc(:,2), '.', 'Color', clr1p);    
    plot(mu(1), mu(2), 'ko', 'MarkerFaceColor', clr1);
    plot(bp(1,:), bp(2,:), '-', 'Color', clr1, 'LineWidth', 2);
    plot(mu2(1), mu2(2), 'ko', 'MarkerFaceColor', clr2);
    plot(bp2(1,:), bp2(2,:), '-', 'Color', clr2, 'LineWidth', 2);
%     xlim(lm); ylim(lm);
    axis equal;
    title('YN1 and YN2 in NB1(1:2)');
    
    plot.subtitle(D.datestr, 'FontSize', 16);

    fnm = ['plots/newAndOldIrrelevant/' dts{ii} '.png'];
%     fnm = 'plots/tmp.png';
    saveas(gcf, fnm);
end

%%

dts = io.getAllowedDates();
% dts = io.getDates();
baseDir = 'data/fits/savedFull';

for ii = 5%1:numel(dts)
%     X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
    NB1 = B1.fDecoder.NulM2;
    NB2 = B2.fDecoder.NulM2;
        
    Bsr = (NB2*NB2')*RB1;
    Bsn1 = (NB2*NB2')*NB1(:,1:2);
    Bsn2 = (NB2*NB2')*NB1(:,3:4);
    Bsn3 = (NB2*NB2')*NB1(:,5:6);
    Bsn4 = (NB2*NB2')*NB1(:,7:8);
    Bss = {Bsr Bsn1 Bsn2 Bsn3 Bsn4};

    gs = B2.thetaActualGrps;
    grps = sort(unique(gs));
    errs = nan(numel(Bss), numel(D.hyps),numel(unique(gs)));    
    nms = {D.hyps.name};
    hix = ismember(nms, {'habitual', 'cloud', 'unconstrained'});
    inds = 1:numel(D.hyps);
    hinds = inds(hix);
    
    for kk = 1:numel(Bss)
        Bsc = Bss{kk};
        
        if kk == 1
            ll = 0;
            plot.init;
        end
        for jj = 1:numel(D.hyps)
            Y = D.hyps(1).latents*Bsc;
            Yh = D.hyps(jj).latents*Bsc;

            if kk == 1 && sum(jj == hinds) > 0
                ll = ll + 1;
                subplot(1,numel(hinds),ll); hold on;
                
                clrs = cbrewer('div', 'RdYlGn', numel(grps));
                for mm = 1:numel(grps)
                    ig = gs == grps(mm);
                    Yc = Y(ig,:);
                    Yd = Yh(ig,:);
                    [bp, mu] = tools.gauss2dcirc(Yc, 1);
                    [bp2, mu2] = tools.gauss2dcirc(Yd, 1);
                    clr1 = clrs(mm,:); clr2 = clr1;
                    plot(mu(1), mu(2), 'ko', 'MarkerFaceColor', clr1);
%                     plot(bp(1,:), bp(2,:), '-', 'Color', clr1, 'LineWidth', 2);
                    plot(mu2(1), mu2(2), 'ws', 'MarkerFaceColor', clr2);
%                     plot(bp2(1,:), bp2(2,:), '--', 'Color', clr2, 'LineWidth', 2);
                    plot([mu(1) mu2(1)], [mu(2) mu2(2)], '-', 'Color', clr1);
                end
                xlabel(D.hyps(jj).name);
%                 axis equal;
            end
            errs(kk,jj,:) = score.quickScore(Y, Yh, gs);
        end
    end
    plot.subtitle([D.datestr ' in NB2, RB1'], 'FontSize', 16);
    
    set(gcf, 'PaperPosition', [200 200 1200 300]);
    
    fnm = ['plots/newAndOldIrrelevant/plots_' D.datestr '.png'];
%     fnm = 'plots/tmp.png';
    print(gcf, fnm, '-dpng');
    
    continue;
    
    plot.init;
    nbs = 5;
    c = 0;
    for kk = 1:nbs
%         plot.init;
        c = c+1;
        subplot(nbs,2,c); hold on;        
        for jj = hinds
            plot(grps, squeeze(errs(kk,jj,:)));
        end
        if kk == nbs
            legend(nms(hix));
        end

        c = c+1;
        subplot(nbs,2,c); hold on;
        bar(1:numel(hinds), mean(squeeze(errs(kk,hix,:)),2), 'FaceColor', 'w');
        set(gca, 'XTick', 1:numel(hinds));
        set(gca, 'XTickLabel', nms(hix));
        
        if kk == 1
            title('YR1');
        else
            title(['YN1(' num2str(2*(kk-1)-1) ':' num2str(2*(kk-1)) ')']);
        end
        ylabel('mean error');
    end
    plot.subtitle(D.datestr, 'FontSize', 16);
    set(gcf, 'Position', [200 200 600 700]);
    
    fnm = ['plots/newAndOldIrrelevant/scores_' D.datestr '.png'];
%     fnm = 'plots/tmp.png';
    saveas(gcf, fnm);
end

