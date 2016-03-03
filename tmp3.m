D = io.quickLoadByDate(4, ...
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

%%

xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));
smth = 100;

figure; set(gcf, 'color', 'w');
for ii = 1:numel(grps)
    ixg = grps(ii) == gs;
    ysc = ys(ixg,:);
    xsc = xs(ixg,:);
    yrc = YR(ixg,:);
    ync = YN(ixg,:);
    yac = Y(ixg,:);
    
    ind = prctile(xsc(xsc >= xs1 & xsc <= xs2), 75);
%     ind = round(xs1 + 0.75*(xs2-xs1));
    ixt = xsc >= ind & xsc <= xs2;
    [A,B,r,U0,V0] = canoncorr(ysc(ixt,:), yac(ixt,:));
    U = (ysc - repmat(mean(ysc(ixt,:)),size(ysc,1),1))*A;
    V = (yac - repmat(mean(yac(ixt,:)),size(yac,1),1))*B;
    
    subplot(4,2,ii); set(gca, 'FontSize', 14); hold on;
    
    ylim([-1 1]);
    plot([xs1 xs1], ylim, 'k--');
    plot([xs2 xs2], ylim, 'k--');
    plot([ind ind], ylim, 'r--');    
    plot(xsc, smooth(xsc, U, smth), '-', 'Color', clrs(ii,:), 'LineWidth', 3);
    plot(xsc, smooth(xsc, V, smth), 'k-');
%     plot(xsc(ixt), smooth(xsc(ixt), U0, 200), 'g-');
    plot(xsc(ixt), smooth(xsc(ixt), V0, smth*0.8), 'r-');
end
