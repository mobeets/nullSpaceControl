
nms = {'habitual', 'pruning', 'pruning-1', 'cloud', 'cloud-og', ...
    'mean shift prune', 'mean shift', 'unconstrained'};
nms = {'habitual', 'pruning', 'cloud', 'cloud-1'};
hypopts = struct('nBoots', 0, 'obeyBounds', false, ...
    'scoreGrpNm', 'thetaActualGrps');
lopts = struct('postLoadFcn', @io.makeImeDefault);
popts = struct();
pms = struct();
dts = io.getAllowedDates();

for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    inds = 2:numel(D.score);
    figure(1);
    subplot(2,3,ii); hold on;
    plot.barByHypQuick(D.score(inds), 'errOfMeans');
    title(dtstr);
    figure(2);
    subplot(2,3,ii); hold on;
    plot.errorByKin(D.score(inds), 'errOfMeansByKin');
    title(dtstr);
    
    figure(3); clf;
    plot.errorByKin(D.score(inds), 'errOfMeansByKin');
    title(dtstr);
    saveas(gcf, 'plots/tmp.png');
end

% figure(1);
% saveas(gcf, ['plots/pruningInverse/' dtstr '_avg.png']);
% figure(2);
% saveas(gcf, ['plots/pruningInverse/' dtstr '_byKin.png']);

%%

plot.init;
for ii = 1:numel(dts)
    dtstr = dts{ii}
    X = load(['data/fits/' dtstr '.mat']); D = X.D;

    B1 = D.blocks(1);
    B2 = D.blocks(2);

    NB = B2.fDecoder.NulM2;
    RB = B2.fDecoder.RowM2;
    Y1 = B1.latents;
    Y2 = B2.latents;
    YN1 = Y1*NB;
    YN2 = Y2*NB;
    YR1 = Y1*RB;
    YR2 = Y2*RB;

    nt1 = size(Y1,1);
    nt2 = size(Y2,1);
    dists = nan(nt2,1);
    inds = nan(nt2,1);

    dsN = pdist2(YN2, YN1);
    dsR = pdist2(YR2, YR1);
    dsA = pdist2(Y2, Y1);
    [distsN, indsN] = min(dsN, [], 2);
    [distsR, indsR] = min(dsR, [], 2);
    [distsA, indsA] = min(dsA, [], 2);
    
%     dsNr = diag(pdist2(YR2, YR1(indsN,:)));
%     dsRn = diag(pdist2(YN2, YN1(indsR,:)));
%     plot.init;
%     plot(distsN, dsNr, '.');
%     xlabel('closest pt: distance in null space');
%     ylabel('distance in row space');
%     plot.init;
%     plot(distsR, dsRn, '.');
%     xlabel('closest pt: distance in row space');
%     ylabel('distance in null space');
    
%     plot.init;
%     bins = linspace(0, round(max(distsR)), 30);
%     hist(distsR, bins);
%     plot([mean(distsR) mean(distsR)], ylim, 'r--');
%     [mean(distsR > mean(distsR)) mean(distsR > median(distsR))]
%     continue;

    % grpNm = 'thetaGrps';
    grpNm = 'thetaActualGrps';
%     grpNm = 'thetaActualGrps16';
    ZA = YN1(indsN,:);
    ZB = YN1(indsR,:);
%     ZC = YN1(indsR,:);


%     ixT = distsR > prctile(distsR, 60);

%     ixs = cell(numel(pcs)-1,1);
% %     pcs = [1 25 50 75 100];
%     pcs = [1 33 66 95 100];
%     for jj = 1:numel(pcs)-1
%         ixs{jj} = distsR > prctile(distsR, pcs(jj)) & distsR <= prctile(distsR, pcs(jj+1));
%     end
%     ixs{end} = distsR > prctile(distsR, 20) | distsR < prctile(distsR, pcs(end-1));
    
    gs1 = B1.(grpNm);
    gsA = gs1(indsN);
    gsB = gs1(indsR);
    gs2 = B2.(grpNm);
    grps = sort(unique(gs2));

    gs2tmp = B2.thetas;
    gsAtmp = B1.thetas; gsAtmp = gsAtmp(indsN);
    dst = @(d1,d2) abs(mod((d1-d2 + 180), 360) - 180);
    ixT = arrayfun(@(t) dst(gs2tmp(t), gsAtmp(t)) <= 45, 1:size(gs2tmp,1))';

%     scs = nan(numel(grps), 4);
    scs = nan(numel(grps), numel(ixs)+2);
    for jj = 1:numel(grps)
%         ixA = gsA == grps(jj);
%         ixB = gsB == grps(jj);
        ix2 = gs2 == grps(jj);

    %     muA = mean(ZA(ixA,:));
    %     muB = mean(ZB(ixB,:));
        muA = nanmean(ZA(ix2,:));
        muB = nanmean(ZB(ix2,:));
        muC = nanmean(ZA(ix2 & ixT,:));
        muD = nanmean(ZA(ix2 & ~ixT,:));
        mu2 = nanmean(YN2(ix2,:));

        scs(jj,1) = norm(muA - mu2);
        scs(jj,2) = norm(muB - mu2);
        scs(jj,3) = norm(muC - mu2);
        scs(jj,4) = norm(muD - mu2);
        
%         for kk = 1:numel(ixs)
%             muC = nanmean(ZB(ix2 & ixs{kk},:));
%             scs(jj,kk+2) = norm(muC - mu2);
%         end
    end
    mean(scs)

%     plot.init;
    subplot(2,3,ii); hold on;
    for jj = 1:size(scs,2)
        plot(grps, scs(:,jj), '-o', 'LineWidth', 4);
    end
%     legend({'closeNull', 'cloud', '1-25', '25-50', '50-75', '75-100'});
    legend({'closeNull', 'cloud', 'A', 'B'});

    xlabel(grpNm);
    ylabel('errOfMeans');
    title(dtstr);
    lbls = arrayfun(@num2str, grps, 'uni', 0);
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabel', lbls');            
    set(gca, 'XTickLabelRotation', 45);
    title(D.datestr);
    
%     saveas(gcf, ['plots/bestSampling/v3_' dtstr '.png']);
end
% saveas(gcf, ['plots/bestSampling/v5.png']);


%%

for ii = 1:numel(dts)
    dtstr = dts{ii}
    X = load(['data/fits/' dtstr '.mat']); D = X.D;
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);

    NB = B2.fDecoder.NulM2;
    RB = B2.fDecoder.RowM2;
    Y1 = B1.latents;
    Y2 = B2.latents;
    YN1 = Y1*NB;
    YN2 = Y2*NB;
    YR1 = Y1*RB;
    YR2 = Y2*RB;

    dsN = pdist2(YN2, YN1);
    [distsN, indsN] = min(dsN, [], 2);
    dsR = pdist2(YR2, YR1);
    [distsR, indsR] = min(dsR, [], 2);

%     grpNm = 'thetaActuals';
    grpNm = 'thetas';
    gs1 = B1.(grpNm);
    gsA = gs1(indsN);
    gsB = gs1(indsR);
    gs2 = B2.(grpNm);
    
    plot.init;
    
%     bins = score.thetaCenters(8);
%     [c,b] = hist(gs1, bins);
%     ys1 = c./trapz(b,c);
%     [c,b] = hist(gsA, bins);
%     ysA = c./trapz(b,c);
%     [c,b] = hist(gsB, bins);
%     ysB = c./trapz(b,c);
%     [c,b] = hist(gs2, bins);
%     ys2 = c./trapz(b,c);
%     plot(bins, ys1, '-', 'LineWidth', 4);
%     plot(bins, ys2, '-', 'LineWidth', 4);
%     plot(bins, ysA, '-', 'LineWidth', 2);
%     plot(bins, ysB, '-', 'LineWidth', 2);
%     title(dtstr);
%     legend({'Blk1', 'Blk2', 'closeNull', 'cloud'});

    
%     subplot(2,2,1); hold on;
%     hist(gs1, 30);
%     title(['observed ' grpNm]);
%     subplot(2,2,2); hold on;
%     hist(gsA, 30);
%     title(['nearest intuitive ' grpNm]);
%     subplot(2,2,3); hold on;
%     hist(gsB, 30);
%     title(['cloud ' grpNm]);
% %     subplot(2,2,4); hold on;
% %     hist(gs1, 30);
%     plot.subtitle(dtstr);
%     continue;
    


%     xlim([0 360]);
%     ylim([0 360]);
%     plot(xlim, ylim, 'k-', 'LineWidth', 4);
    
%     figNm = [dtstr '-paired'];
%     plot(gsA, gsB, '.');
%     xlabel(['nearest intuitive in null space ' grpNm]);
%     ylabel(['cloud ' grpNm]);

%     figNm = [dtstr '-nearestNull'];
%     plot(gs2, gsA, '.');
%     xlabel(['observed ' grpNm]);
%     ylabel(['nearest intuitive in null space ' grpNm]);
%     title(D.datestr);
    
%     figNm = [dtstr '-cloud'];
%     plot(gs2, gsB, '.');
%     xlabel(['observed ' grpNm]);
%     ylabel(['cloud sampled ' grpNm]);
%     title(D.datestr);
    
    grps = sort(unique(B2.thetaGrps));
    lbls = arrayfun(@num2str, grps, 'uni', 0);
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabel', lbls');            

%     set(gca, 'YTick', grps);
%     set(gca, 'YTickLabel', lbls');

%     saveas(gcf, ['plots/bestSampling/sampledThetas/' figNm '.png']);
end
    