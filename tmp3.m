
B1 = D.blocks(1);
B2 = D.blocks(2);


inds = prctile(B2.trial_index, [20 80]);
indEarly = inds(1); indLate = inds(2);

ixEarly = B2.trial_index < indEarly;
ixLate = B2.trial_index > indLate;

% close all;
B = B2;
xs = B.thetas + 180;
ys = B.angError;
gs = B.targetAngle;
ix0 = true(size(xs));

grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));
figure; set(gcf, 'color', 'w');
hold on; box off; set(gca, 'FontSize', 14);
for ii = 1:numel(grps)
    ix = (gs == grps(ii)) & ix0;
    scatter(xs(ix), ys(ix), 120, clrs(ii,:), '.');
end
set(gca, 'XTick', grps);

%%

ys1 = B2.angError(ixEarly);
ys2 = B2.angError(ixLate);
gs1 = B2.thetaGrps(ixEarly);
gs2 = B2.thetaGrps(ixLate);

% ys1 = B1.angError; gs1 = B1.thetaGrps;
% ys2 = B2.angError; gs2 = B2.thetaGrps;

grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));
figure; set(gcf, 'color', 'w');
title(D.datestr);
subplot(1,2,1);
hold on; box off; set(gca, 'FontSize', 14);
for ii = 1:numel(grps)
    ix1 = (gs1 == grps(ii));
    ix2 = (gs2 == grps(ii));
%     scatter(median(ys1(ix1)), median(ys2(ix2)), 120, clrs(ii,:), 'o', 'filled');
    scatter(grps(ii), median(ys1(ix1)) - median(ys2(ix2)), 120, ...
        clrs(ii,:), 'o', 'filled');
%     scatter(median(ys1(ix1)) - median(ys2(ix2)), mean(ys(ix1)) - mean(ys(ix2)), 120, ...
%         clrs(ii,:), 'o', 'filled');
end
xlabel('\theta'); ylabel('improvement in angError, early to late');
% set(gca, 'XTick', grps);

%%

B = D.blocks(2);
NB = B.fDecoder.NulM2;
Y = D.hyps(1).latents;
Yh = D.hyps(2).latents;

[~,~,v] = svd(Y*NB);
NB = NB*v;
YN = Y*NB;
YNh = Yh*NB;

xs = B.trial_index;
ys = arrayfun(@(ii) norm(YNh(ii,:) - YN(ii,:)), 1:size(YN,1));
gs = B.thetaGrps;
grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));
%%
subplot(1,2,2);
% figure; set(gcf, 'color', 'w');
hold on; box off; set(gca, 'FontSize', 14);
for ii = 1:numel(grps)
    ix = (gs == grps(ii));
%     plot(grps(ii), sum(ix), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    plot(xs(ix), smooth(xs(ix), ys(ix), 300), 'Color', clrs(ii,:), 'LineWidth', 3);
end
legend(arrayfun(@(c) num2str(c), grps, 'uni', 0), 'Location', 'BestOutside');
xlabel('trial #'); ylabel('norm(habitual - actual) in Nul');
title(D.datestr);

%%

B = Bs{1};
xs = B.angError;
YN = B.latentsNul;
YNh = B.habitualNul;
gs = B.thetaGrps;
ys = B.progress;

clrs = cbrewer('div', 'RdYlGn', numel(grps));
figure; set(gcf, 'color', 'w');
title(D.datestr);
hold on; box off; set(gca, 'FontSize', 14);
for ii = 1:numel(grps)
    ix = (gs == grps(ii));
    YNhc = mean(YNh(ix,:));
    YNc = mean(YN(ix,:));    
    scatter(median(ys(ix)), norm(YNc - YNhc), 120, clrs(ii,:), 'o', 'filled');
end
xlabel('\theta'); ylabel('norm error');

