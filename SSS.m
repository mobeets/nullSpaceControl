
baseDir = 'data/fits/allHypsAgain';
dts = io.getDates();

nhyps = 10;
ngrps = 16;
grps = score.thetaCenters(ngrps);
Cov1F = cell(numel(dts), ngrps, nhyps);
Cov1S = cell(numel(dts), ngrps, nhyps);
Cov2F = cell(numel(dts), ngrps, nhyps);
Cov2S = cell(numel(dts), ngrps, nhyps);
Err2S = nan(numel(dts), ngrps, nhyps);
Err12 = nan(numel(dts), ngrps);
for jj = 1:numel(dts)
    X = load(fullfile(baseDir, [dts{jj} '.mat'])); D = X.D;

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    Y2 = B2.latents;    

    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    RB2 = B2.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    
    SS0 = (NB2*NB2')*RB1;    
    [SSS,s,v] = svd(SS0, 'econ');
%     SS0 = (RB1*RB1')*NB2;
%     [SSS,s,v] = svd(SS0, 'econ');
%     SSS = SSS(:,1:2);
    
    gs1 = score.thetaGroup(tools.computeAngles(Y1*RB1), grps);
    gs2 = score.thetaGroup(tools.computeAngles(Y2*RB1), grps);
%     gs1 = B1.thetaActualImeGrps16;
%     gs2 = B2.thetaActualImeGrps16;

    for ii = 1:numel(grps)
        ix1 = gs1 == grps(ii);
        ix2 = gs2 == grps(ii);
        Y1c = Y1(ix1,:);        
        for kk = 1:numel(D.hyps)
            Y2c = D.hyps(kk).latents(ix2,:);
            Cov2S{jj,ii,kk} = nancov(Y2c*SSS);
            Cov2F{jj,ii,kk} = nancov(Y2c);
            Cov1S{jj,ii,kk} = nancov(Y1c*SSS);
            Cov1F{jj,ii,kk} = nancov(Y1c);
            Err2S(jj,ii,kk) = score.compareCovs(Y2c*SSS, Y2(ix2,:)*SSS);
        end
        Err12(jj,ii) = score.compareCovs(Y2(ix2,:)*SSS, Y1c*SSS);
    end
    
end

%% plot cov ellipses

kNmA = 'observed';
kNmB = 'uncontrolled-uniform';
CovA = Cov1S;
CovB = Cov2S;

hypnms = {D.hyps.name};
kkA = find(strcmp(hypnms, kNmA));
kkB = find(strcmp(hypnms, kNmB));
clrA = allHypClrs(kkA,:);
clrB = allHypClrs(kkB,:);
sigMult = 2;

if isequal(kNmA, kNmB)
    clrB = [0.6 0.6 0.6];
elseif strcmpi(kNmA, 'observed') && isequal(CovA, Cov1S)
    clrA = [0.6 0.6 0.6];
end

errs = nan(size(Cov2S,1), size(Cov2S,2));
covAreaFcn = @trace;
errFcn = @(C0, Ch) covAreaFcn(Ch)/covAreaFcn(C0);

plot.init;
dstep = 10;
for jj = 1:size(Cov2S,1)
    for ii = 1:size(Cov2S,2)
        C1 = CovA{jj,ii,kkA};
        C2 = CovB{jj,ii,kkB};
        [bpA, ~, ~] = tools.gauss2dcirc([], sigMult, C1);
        [bpB, ~, ~] = tools.gauss2dcirc([], sigMult, C2);
        errs(jj,ii) = errFcn(C1, C2);
        bpA(1,:) = bpA(1,:) + (ii-1)*dstep;
        bpB(1,:) = bpB(1,:) + (ii-1)*dstep;
        bpA(2,:) = bpA(2,:) - (jj-1)*dstep;
        bpB(2,:) = bpB(2,:) - (jj-1)*dstep;
        plot(bpA(1,:), bpA(2,:), '-', 'Color', clrA);
        plot(bpB(1,:), bpB(2,:), '-', 'Color', clrB);
    end
end

box off; axis off;
plot.subtitle([kNmA ' and ' kNmB]);
set(gcf, 'Position', [0 0 700 600]);

plot.init;
clrs = cbrewer('div', 'RdBu', 11);
colormap(clrs);
imagesc(flipud(log(errs)));
caxis([-2 2]);
axis off; box off;

plot.init;
bar(mean(log(errs),2), 'FaceColor', 'w');

%% image heatmap of cov errors

plot.init;
c = 1;
for kk = [2 4 5 6 7 10]
    cv = squeeze(Err2S(:,:,kk));    
%     cv = nanmean(cv, 2);
    subplot(2, 3, c); hold on;
    imagesc(flipud(cv));
    axis image;
    box off;
    xlabel(hypnms{kk});
    caxis([0 3]);
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    c = c + 1;
end

%% plot avg cov ellipse error

plot.init;
c = 1;
hinds = [2 4 5 6 7 10];
for kk = hinds
    cv = squeeze(Err2S(:,:,kk));
%     cv = nanmean(cv, 2);
    cv = cv(:);
    ps = prctile(cv, [25 50 75]);
    bar(c, ps(2), 'FaceColor', 'w');
    plot([c c], [ps(1) ps(3)], 'k-');
    c = c + 1;
end
set(gca, 'XTick', 1:numel(hinds));
set(gca, 'XTickLabel', {D.hyps(hinds).name});
set(gca, 'XTickLabelRotation', 45);
ylim([0 3]);

%%

covAreaFcn = @trace;
%     sssFcn = @(Yc, SSS) (covAreaFcn(nancov(Yc*SSS))/size(SSS,2)) / ...
%         (covAreaFcn(nancov(Yc))/size(Yc,2));
%     sssFcn = @(Yc, SSS) covAreaFcn(nancov(Yc*SSS))/covAreaFcn(nancov(Yc));
%     sssFcn = @(Yc, SSS, Yd) covAreaFcn(nancov(Yc*SSS))/covAreaFcn(nancov(Yd));
%     sssFcn = @(Yc, SSS, Yd) (covAreaFcn(nancov(Yc*SSS))/size(SSS,2))/(covAreaFcn(nancov(Yd))/size(Yd,2));
    
%     sssFcn = @(Yc, SSS) (covAreaFcn(nancov(Yc*SSS))/size(Yc,2));

%%


covAreaFcn = @trace;

B1 = D.blocks(1);
B2 = D.blocks(2);
Y1 = B1.latents;
Y2 = B2.latents;    

decNm = 'fDecoder';
RB1 = B1.(decNm).RowM2;
RB2 = B2.(decNm).RowM2;
NB2 = B2.(decNm).NulM2;

SS0 = (NB2*NB2')*RB1;    
[SSS,s,v] = svd(SS0, 'econ');
%     SS0 = (RB1*RB1')*NB2;
%     [SSS,s,v] = svd(SS0, 'econ');
%     SSS = SSS(:,1:2);

gs1 = score.thetaGroup(tools.computeAngles(Y1*RB1), grps);
gs2 = score.thetaGroup(tools.computeAngles(Y2*RB1), grps);

gs1 = B1.thetaActualImeGrps16;
gs2 = B2.thetaGrps16;

%     sssFcn = @(Yc, SSS) (covAreaFcn(nancov(Yc*SSS))/size(SSS,2)) / ...
%         (covAreaFcn(nancov(Yc))/size(Yc,2));
sssFcn = @(Yc, SSS) covAreaFcn(nancov(Yc*SSS))/covAreaFcn(nancov(Yc));

ss = [];
plot.init;
for ii = 10%1:numel(grps)
    ix1 = gs1 == grps(ii);
    ix2 = gs2 == grps(ii);
    subplot(4,4,ii); hold on;
    Yc1 = D.hyps(2).latents(ix2,:)*SSS;    
    plot(Yc1(:,1), Yc1(:,2), '.');
    Yc2 = D.hyps(6).latents(ix2,:)*SSS;
    plot(Yc2(:,1), Yc2(:,2), '.');
    
    v1 = sssFcn(D.hyps(2).latents(ix2,:), SSS);
    v2 = sssFcn(D.hyps(6).latents(ix2,:), SSS);
    ss = [ss; v1 v2];
    xlabel(v1);
    ylabel(v2);
%     '----'
end

%% scatter of all hyps

plot.init;
ncols = 3; nrows = 3;
for kk = 2:numel(D.hyps)
    subplot(ncols, nrows, kk-1); hold on;
    vo = Rs(:,:,1);
    vh = Rs(:,:,kk);
    plot(vo(:), vh(:), 'k.');
    mx = max(max(vo(:)), max(vh(:)));
    ylim([0 mx]); xlim(ylim); plot(xlim, ylim, 'k--');
    title(D.hyps(kk).name);
end

%% bar plot

plot.init;
for kk = 1:numel(D.hyps)
    rc = Rs(:,:,kk);
    rc = mean(rc,2);
    ps = prctile(rc(:), [10 50 90]);
    bar(kk, ps(2), 'FaceColor', 'w');
    plot([kk kk], [ps(1) ps(3)], 'k-');
    continue;
    
    
    vc = mean(rc(:));
    bar(kk, vc, 'FaceColor', 'w');
end
set(gca, 'XTick', 1:numel(D.hyps));
set(gca, 'XTickLabel', {D.hyps.name});
set(gca, 'XTickLabelRotation', 45);
ylim([0 3]);

%% heat map of observed

hypNm = 'baseline';
hypnms = {D.hyps.name};
hypInd = find(strcmp(hypnms, hypNm));
plot.init;
clrs = cbrewer('div', 'RdBu', 11);
colormap(clrs);
set(gca, 'XTick', 1:2:size(Rs,2));
set(gca, 'XTickLabel', grps(1:2:end));
set(gca, 'XTickLabelRotation', 45);
set(gca, 'YTick', 1:1:size(Rs,1));
imagesc(Rs(:,:,hypInd));
caxis([0 2]);
title(D.hyps(hypInd).name);
