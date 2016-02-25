
D = io.quickLoadByDate(1, ...
    struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360));
B = D.blocks(2);

Y = B.latents;
RB = B.fDecoder.RowM2;
NB = B.fDecoder.NulM2;
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
for ii = 1:numel(xbs)-1
    ixt = xs >= xbs(ii) & xs <= xbs(ii+1);    
    for jj = 1:numel(grps)
        ixg = grps(jj) == gs;
        ysc = ys(ixt&ixg,:);
        xsc = xs(ixt&ixg,:);
        yrc = YR(ixt&ixg,:);
        ync = YN(ixt&ixg,:);
        
        [Ar,Br,rr,Ur,Vr] = canoncorr(ysc, yrc);
        [An,Bn,rn,Un,Vn] = canoncorr(ysc, ync);
        rrs(ii,jj) = rr;
        rns(ii,jj) = rn;
    end
end

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
xlabel('trial #');
ylabel('corr(YN, progress)');

subplot(2,2,2);
set(gca, 'FontSize', 14);
hold on;
for jj = 1:numel(grps)
    plot(rrs(:,jj), rns(:,jj), 'ko', 'MarkerFaceColor', clrs(jj,:));
end
xlabel('corr(YR, progress)');
ylabel('corr(YN, progress)');

plot.subtitle(D.datestr);
