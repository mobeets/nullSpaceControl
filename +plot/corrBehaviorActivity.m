
D = io.quickLoadByDate(2, ...
    struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360));
B = D.blocks(2);
RB = B.fDecoder.RowM2;
NB = B.fDecoder.NulM2;

% B = D.trials;
Y = B.latents;
YR = Y*RB;
YN = Y*NB;

xs = B.trial_index;
ys = B.progress;
gs = B.thetaGrps;
grps = sort(unique(gs(~isnan(gs))));
clrs = cbrewer('div', 'RdYlGn', numel(grps));

xsa = unique(xs);
tinds = min(xsa):max(xsa);
% xbs = [1 round(prctile(tinds, [25 50 75])) max(tinds)];
nbins = round(range(tinds)/70);
xbs = round(prctile(tinds, linspace(1,100,nbins)));

rrs = nan(numel(xbs)-1, numel(grps));
rns = nan(size(rrs));
prgs = nan(size(rrs));

lags = [1 5 20 50];%1:5:100;
zrs = cell(numel(xbs)-1, numel(grps));
zns = cell(size(zrs));
Ub = cell(size(zrs));
Vb = cell(size(zrs));
rb_all = nan([size(rrs) 2]);

for ii = 1:numel(xbs)-1
    ixt = xs >= xbs(ii) & xs <= xbs(ii+1);    
    for jj = 1:numel(grps)
        ixg = grps(jj) == gs;
        ysc = ys(ixt&ixg,:);
        xsc = xs(ixt&ixg,:);
        yrc = YR(ixt&ixg,:);
        ync = YN(ixt&ixg,:);
        yac = Y(ixt&ixg,:);
        
        zrs{ii,jj} = tools.pairwiseLags(yrc, lags);
        zns{ii,jj} = tools.pairwiseLags(ync, lags);
        
        [Ar,Br,rr,Ur,Vr] = canoncorr(ysc, yrc);
        [An,Bn,rn,Un,Vn] = canoncorr(ysc, ync);
        [Aa,Ba,ra,Ua,Va] = canoncorr(ysc, yac);
        [~,~,rb,Ub{ii,jj},Vb{ii,jj}] = canoncorr(yrc, ync);
        rb_all(ii,jj,:) = rb;
%         [~,~,rr,~,~] = canoncorr(Va, yrc);
%         [~,~,rn,~,~] = canoncorr(Va, ync);
%         rr = rr/ra;
%         rn = rn/ra;
        
        rrs(ii,jj) = rr;
        rns(ii,jj) = rn;
        prgs(ii,jj) = median(ysc);
    end
end

%%

close all;
xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));

figure; set(gcf, 'color', 'w');
for jj = 1:numel(grps)
    subplot(2,4,jj); hold on; set(gca, 'FontSize', 14);
    plot(xbs(2:end), rb_all(:,jj,1), '-');
    for ii = 1:numel(xbs)-1
        xx = Ub{ii,jj}(:,1);
        yy = Vb{ii,jj}(:,1);
%         plot(xx,yy,'.');
    end
    ylim([0 1]);
    plot([xs1 xs1], ylim, 'r--');
    plot([xs2 xs2], ylim, 'r--');
    plot(xlim, [0 0], 'k--');
end

%%

figure; set(gcf, 'color', 'w');
for jj = 1:numel(grps)
    subplot(4,2,jj); set(gca, 'FontSize', 14);
    clrs = gray(numel(xbs));
    rhos_all{jj} = nan(numel(xbs)-1, numel(lags));
    for ii = 1:numel(xbs)-1
        hold on;
        zr = zrs{ii,jj};
        zn = zns{ii,jj};
        rhos = nan(size(zr,2),1);        
        for kk = 1:size(zr,2)
            ix = ~isnan(zr(:,kk,1) + zn(:,kk,1));
            if sum(ix) == 0
                continue;
            end
            y0 = squeeze(zr(ix,kk,:));
            y1 = squeeze(zn(ix,kk,:));            
            [~,~,rrc,~,~] = canoncorr(y0, y1);
            rhos(kk) = rrc(1);
%             rhos(kk) = corr(y0, y1);
            rhos_all{jj}(ii,kk) = rhos(kk);
        end
        clr = clrs(end-ii+1,:);
        plot(lags, rhos, '.', 'Color', clr);
        plot(lags, rhos, '-', 'Color', clr, 'LineWidth', 3);
    end
    plot(xlim, [0 0], 'k--');
    ylim([-1 1]);
end
xlabel('lags');
ylabel('corr(YN, YR)');

%%

xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));

figure; set(gcf, 'color', 'w');
for jj = 1:numel(grps)
    subplot(4,2,jj); set(gca, 'FontSize', 14); hold on;
    rh = rhos_all{jj};
    for ii = 1:numel(lags)
        plot(xbs(2:end), rh(:,ii), 'k.');
        plot(xbs(2:end), rh(:,ii), 'k-');
    end    
    plot(xlim, [0 0], 'k--');
    ylim([-1 1]);
    plot([xs1 xs1], ylim, 'r--');
    plot([xs2 xs2], ylim, 'r--');
end
xlabel('time');
ylabel('corr(YN, YR)');
plot.subtitle(D.datestr);

%%

xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));

figure;
set(gcf, 'color', 'w');

vs = rrs;
subplot(2,2,1);
set(gca, 'FontSize', 14);
hold on;
for jj = 1:numel(grps)
    plot(xbs(2:end), vs(:,jj), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 3);    
end
plot([xs1 xs1], ylim, 'r--');
plot([xs2 xs2], ylim, 'r--');
xlabel('trial #');
ylabel('corr(YR, progress)');

vs = rns;
subplot(2,2,3);
set(gca, 'FontSize', 14);
hold on;
for jj = 1:numel(grps)
    plot(xbs(2:end), vs(:,jj), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 3);    
end
plot([xs1 xs1], ylim, 'r--');
plot([xs2 xs2], ylim, 'r--');
xlabel('trial #');
ylabel('corr(YN, progress)');

subplot(2,2,2);
% figure; set(gcf, 'color', 'w');
set(gca, 'FontSize', 14);
hold on;
for jj = 1:numel(grps)
%     clf;
    plot3(rrs(:,jj), rns(:,jj), 1:size(rns,1), 'ko', 'MarkerFaceColor', clrs(jj,:));
    plot3(rrs(:,jj), rns(:,jj), 1:size(rns,1), 'k-', 'Color', clrs(jj,:));
%     plot3(diff(rrs(:,jj)), diff(rns(:,jj)), 1:size(rns,1)-1, 'ko', 'MarkerFaceColor', clrs(jj,:));
%     plot3(diff(rrs(:,jj)), diff(rns(:,jj)), 1:size(rns,1)-1, 'k-', 'Color', clrs(jj,:));
%     pause;
end
xlabel('corr(YR, progress)');
ylabel('corr(YN, progress)');

subplot(2,2,4);
set(gca, 'FontSize', 14);
hold on;
for jj = 1:numel(grps)    
    plot(xbs(2:end), prgs(:,jj), '-', 'Color', clrs(jj,:), 'LineWidth', 3);
    plot(xbs(2:end), prgs(:,jj), 'ko', 'MarkerFaceColor', clrs(jj,:));
%     plot(xbs(3:end), diff(prgs(:,jj)), '-', 'Color', clrs(jj,:), 'LineWidth', 3);
%     plot(xbs(3:end), diff(prgs(:,jj)), 'ko', 'MarkerFaceColor', clrs(jj,:));
end
plot([xs1 xs1], ylim, 'r--');
plot([xs2 xs2], ylim, 'r--');
xlabel('time');
% ylabel('\Delta cursor progress');
ylabel('cursor progress');

% plot.subtitle(D.datestr);
