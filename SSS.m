
baseDir = 'data/fits/allHypsAgain';
dts = io.getDates();
% dts = dts(cellfun(@str2num, dts) < 20160101);

nhyps = 10;
ngrps = 16;
grps = score.thetaCenters(ngrps);

Cov1F = cell(numel(dts), ngrps, nhyps);
Cov1R = cell(numel(dts), ngrps, nhyps);
Cov1S = cell(numel(dts), ngrps, nhyps);

Cov2F = cell(numel(dts), ngrps, nhyps);
Cov2R = cell(numel(dts), ngrps, nhyps);
Cov2S = cell(numel(dts), ngrps, nhyps);
ns = nan(numel(dts), ngrps, 2);
es = nan(numel(dts), nhyps, 2);

Err2S = nan(numel(dts), ngrps, nhyps);
Err12 = nan(numel(dts), ngrps);
for jj = 1:numel(dts)
    indir = fullfile(baseDir, [dts{jj} '.mat']);
    if ~exist(indir)
        warning(indir);
        continue;
    end
    X = load(fullfile(baseDir, [dts{jj} '.mat'])); D = X.D;

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    Y2 = B2.latents;    

    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    RB2 = B2.(decNm).RowM2;
    NB1 = B1.(decNm).NulM2;
    NB2 = B2.(decNm).NulM2;
    
    NB = NB2; RB = RB1; % when activity became irrelevant
%     NB = NB1; RB = RB2; % when activity became relevant
    
    SS0 = (NB*NB')*RB;
    [SSS,s,v] = svd(SS0, 'econ');
    gs1 = score.thetaGroup(tools.computeAngles(Y1*RB), grps);
    gs2 = score.thetaGroup(tools.computeAngles(Y2*RB), grps);
    
%     SS1 = (NB1*NB1')*RB2;
%     [SSS,s,v] = svd(SS1, 'econ');
%     gs1 = score.thetaGroup(tools.computeAngles(Y1*RB2), grps);
%     gs2 = score.thetaGroup(tools.computeAngles(Y2*RB2), grps);

    for ii = 1:numel(grps)
        ix1 = gs1 == grps(ii);
        ix2 = gs2 == grps(ii);
        Y1c = Y1(ix1,:);
        ns(jj,ii,:) = [sum(ix1) sum(ix2)];
        for kk = 1:numel(D.hyps)
            es(jj,kk,:) = [D.score(kk).errOfMeans D.score(kk).covError];
            Y2c = D.hyps(kk).latents(ix2,:);
            Cov2S{jj,ii,kk} = nancov(Y2c*SSS);
            Cov2F{jj,ii,kk} = nancov(Y2c);
            Cov2R{jj,ii,kk} = nancov(Y2c*RB);
            Cov1S{jj,ii,kk} = nancov(Y1c*SSS);
            Cov1F{jj,ii,kk} = nancov(Y1c);
            Cov1R{jj,ii,kk} = nancov(Y1c*RB);
            Err2S(jj,ii,kk) = score.compareCovs(Y2c*SSS, Y2(ix2,:)*SSS);
        end
        Err12(jj,ii) = score.compareCovs(Y2(ix2,:)*SSS, Y1c*SSS);
    end
    
end

covAreaFcn = @trace;
for jj = 1:size(Cov2S,1)
    for ii = 1:size(Cov2S,2)
        for kk = 1:size(Cov2S,3)
            Cov1Sa(jj,ii,kk) = covAreaFcn(Cov1S{jj,ii,kk});
            Cov2Sa(jj,ii,kk) = covAreaFcn(Cov2S{jj,ii,kk});
            Cov1Fa(jj,ii,kk) = covAreaFcn(Cov1F{jj,ii,kk});
            Cov2Fa(jj,ii,kk) = covAreaFcn(Cov2F{jj,ii,kk});
            Cov1Ra(jj,ii,kk) = covAreaFcn(Cov1R{jj,ii,kk});
            Cov2Ra(jj,ii,kk) = covAreaFcn(Cov2R{jj,ii,kk});
        end
    end
end

%% plot cov ellipses

kNmA = 'observed';
kNmB = 'cloud';
CovA = Cov1S;
CovB = Cov2S;

% CovAf = Cov1R;
% CovBf = Cov2R;

hypnms = {D.hyps.name};
kkA = find(strcmp(hypnms, kNmA));
kkB = find(strcmp(hypnms, kNmB));
clrA = allHypClrs(kkA,:);
clrB = allHypClrs(kkB,:);
sigMult = 2;

if isequal(kNmA, kNmB)
    clrA = [0.6 0.6 0.6];
elseif strcmpi(kNmA, 'observed') && isequal(CovA, Cov1S)
    clrA = [0.6 0.6 0.6];
end

errs = nan(size(Cov1S));
covAreaFcn = @trace;
errFcn = @(C0, Ch) covAreaFcn(Ch)/covAreaFcn(C0);

plot.init;
dstep = 5;
for jj = 1:size(Cov2S,1)
    for ii = 1:size(Cov2S,2)
        for kk = 1:size(Cov2S,3)
            C1 = CovA{jj,ii,kkA};
            C2 = CovB{jj,ii,kk};
            if isempty(C1) || isempty(C2)
                continue;
            end
            errs(jj,ii,kk) = errFcn(C1, C2);

%             C1f = CovAf{jj,ii,kkA};
%             C2f = CovBf{jj,ii,kk};
%             errs(jj,ii,kk) = errFcn(C1, C2)*errFcn(C2f, C1f);

            if kk == kkA || kk == kkB
                [bpA, ~, ~] = tools.gauss2dcirc([], sigMult, C1);
                [bpB, ~, ~] = tools.gauss2dcirc([], sigMult, C2);
                bpA(1,:) = bpA(1,:) + (ii-1)*dstep;
                bpB(1,:) = bpB(1,:) + (ii-1)*dstep;
                bpA(2,:) = bpA(2,:) - (jj-1)*dstep;
                bpB(2,:) = bpB(2,:) - (jj-1)*dstep;
            end            
            if kk == kkA
                plot(bpA(1,:), bpA(2,:), '-', 'Color', clrA);
            end
            if kk == kkB
                plot(bpB(1,:), bpB(2,:), '-', 'Color', clrB);
            end
        end
    end
end

box off; axis off;
plot.subtitle([kNmA ' and ' kNmB]);
set(gcf, 'Position', [0 0 700 600]);

%% heatmap and barplot

cErr = errs(:,:,kkB);

plot.init;
clrs = cbrewer('div', 'RdBu', 11);
colormap(clrs);
imagesc(flipud(log(cErr)));
caxis([-2 2]);
axis off; box off;

plot.init;
bar(mean(log(cErr),2), 'FaceColor', 'w');

%% plot avg cov ellipse error

doSave = false;
saveDir = 'notes/sfn/imgs';
mnkNm = 'Nelson';
% mnkNm = '';

curHyps = {'minimum', 'baseline', 'uncontrolled-uniform', ...
    'unconstrained', 'habitual', 'cloud'};
[hypInds, hypClrs] = figs.getHypIndsAndClrs(curHyps, hypnms, allHypClrs);
hypInds = [hypInds 1];
hypClrs = [hypClrs; baseClr];

nmsToShow = figs.getHypDisplayNames(hypnms(hypInds), ...
    hypNmsInternal, hypNmsShown);

cErr = log(errs);
if ~isempty(mnkNm)
    ix = io.getMonkeyDateInds(dts, mnkNm);
else
    ix = true(size(cErr,1),1);
end
cErr = cErr(ix,:,:);

plot.init;
c = 1;
for kk = hypInds
    cv = squeeze(cErr(:,:,kk));
%     cv = nanmean(cv, 2);
    cv = cv(:);
    cv = cv(~isinf(cv) & ~isnan(cv));
%     ps = prctile(cv, [25 50 75]);
%     mu = ps(2); es = [ps(1) ps(3)];
    
    mu = mean(cv);
    vs = 2*std(cv)/sqrt(numel(cv));
    es = [mu-vs mu+vs];
    
    bar(c, mu, 'EdgeColor', hypClrs(c,:), 'FaceColor', hypClrs(c,:));
    plot([c c], es, 'k-');
    c = c + 1;
end
set(gca, 'XTick', 1:numel(hypInds));
set(gca, 'XTickLabel', nmsToShow);
set(gca, 'XTickLabelRotation', 45);
set(gca, 'TickDir', 'out');
ylabel('\leftarrow Contraction  Expansion \rightarrow');
xlim([0.5 numel(hypInds)+0.5]);
ylim([-2.5 2.5]);

if ~isempty(mnkNm)
    title(mnkNm);
end
if doSave
    export_fig(gcf, fullfile(saveDir, 'SSS.pdf'));
end

%%

kNm = 'cloud';
kkC = find(strcmp(hypnms, kNm));
As = Cov1Sa(:,:,kkC);
Bs = Cov2Sa(:,:,kkC);
Af = Cov1Fa(:,:,kkC);
Bf = Cov2Fa(:,:,kkC);
errS = Bs./As;
errF = Bf./Af;
errA = (Bs./Bf)./(As./Af);

plot.init; plot(log(errF(:)), log(errS(:)), 'k.'); xlabel('full cov'); ylabel('sss cov');
plot.init; plot(log(errF(:)), log(errA(:)), 'k.'); xlabel('full cov'); ylabel('sss-norm cov');

%% image heatmap of covError

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
