
B = D.blocks(2);

NB = B.fDecoder.NulM2;
if true
    [~,~,v] = svd(B.latents*NB);
    NB = NB*v;
end

% F is normal D; D is D without any filtering on angError
ys = F.hyps(1).latents*NB;
ysh = F.hyps(9).latents*NB;
grps0 = score.thetaGroup(F.blocks(2).thetas, sort(unique(cnts)));

xs = B.thetas;
cnts = B.targetAngle;
grps = score.thetaGroup(xs, sort(unique(cnts)));
allgrps = sort(unique(grps));
allgrps = circshift(allgrps, 4);

%%

close all;
figure; hold on;
set(gca, 'FontSize', 14);

cmap = cbrewer('div', 'RdYlGn', numel(allgrps) + 2);
% cmap = circshift(cmap, floor(numel(allgrps)/2));
for ii = 1:numel(allgrps)
    ix = (grps == allgrps(ii));
%     scatter(allgrps(ii)*ones(sum(ix),1), B.angError(ix));
    zs0 = mean(abs(B.angError(ix)));
%     scatter(allgrps(ii), zs0, 80, 'k', 'filled');
    
    ix = (grps0 == allgrps(ii));
    ys0 = norm(ys(ix,:) - ysh(ix,:));
%     scatter(allgrps(ii), ys0, 80, [0.8 0.2 0.2], 'filled');
    
    scatter(zs0, ys0, 80, 'k', 'filled');
    
end

xlim([0 60]);
ylim([0 70]);
xlabel('mean \theta (mean of angular error)');
ylabel('norm(habitual - observed)');
% xlabel('\theta');
% ylabel('angular error');
set(gcf, 'color', 'w');
