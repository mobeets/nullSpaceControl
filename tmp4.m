%% load

D = io.quickLoadByDate('20120525');
B1 = D.blocks(1);
B2 = D.blocks(2);
Y = B2.latents;
Y1 = B1.latents;
% Yh = pred.condGaussFit(D);
Yh = pred.sameCloudFit(D);
NB = B2.fDecoder.NulM2;
RB = B2.fDecoder.RowM2;
[u,s,v] = svd(Y*NB); NB = NB*v;

%% make 2d

Y1 = B1.latents*NB;
Y2 = B2.latents*NB;
Yh = Yh*NB;
Y1 = Y1(:,1:2);
Y2 = Y2(:,1:2);
Yh = Yh(:,1:2);
% Y1 = Y2;

%% visualize distances

ths1 = B1.thetas;
rs1 = B1.latents*RB;
n1 = size(Y1,1);
n2 = size(Y2,1);

% pick random pt
ind = randi(n2);
th = B2.thetas(ind);
r = B2.latents(ind,:)*RB;
trg = B2.thetaGrps(ind);

% distance of all pts in thetas
dsf = @(Z,z) bsxfun(@(d1,d2) abs(mod((d1-d2 + 180), 360) - 180), Z, z);
dsTh = dsf(ths1, th);

% distance of all pts in row space
dsr = @(Z,z) sqrt(sum(bsxfun(@plus, Z, -z).^2,2));
dsRw = dsr(rs1, r);

clrNear = [0.04 0.2 0.5];
clrFar = [0.78 0.86 0.94];

% close all;
figure; set(gcf, 'color', 'w');

ixNearTh = dsTh <= 22.5; %prctile(dsTh, 20);
ixNearRw = dsRw <= 0.35; %prctile(dsRw, 20);
ixNearTrg = B1.thetaGrps == trg;

subplot(2,2,1);
ixNear = ixNearTrg;
hold on; set(gca, 'FontSize', 14); axis off;
plot(Y1(~ixNear,1), Y1(~ixNear,2), '.', 'Color', clrFar, 'MarkerSize', 8);
plot(Y1(ixNear,1), Y1(ixNear,2), '.', 'Color', clrNear, 'MarkerSize', 8);
plot(Y2(ind,1), Y2(ind,2), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
title('same thetaGrp');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');

subplot(2,2,2);
ixNear = ixNearTh;
hold on; set(gca, 'FontSize', 14); axis off;
plot(Y1(~ixNear,1), Y1(~ixNear,2), '.', 'Color', clrFar, 'MarkerSize', 8);
plot(Y1(ixNear,1), Y1(ixNear,2), '.', 'Color', clrNear, 'MarkerSize', 8);
plot(Y2(ind,1), Y2(ind,2), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
title('habitual: thetaDist <= 22.5');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');

subplot(2,2,3);
ixNear = ixNearRw;
hold on; set(gca, 'FontSize', 14); axis off;
plot(Y1(~ixNear,1), Y1(~ixNear,2), '.', 'Color', clrFar, 'MarkerSize', 8);
plot(Y1(ixNear,1), Y1(ixNear,2), '.', 'Color', clrNear, 'MarkerSize', 8);
plot(Y2(ind,1), Y2(ind,2), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
title('cloud (raw): rowDist <= 0.35');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');

subplot(2,2,4);
ixNear = ixNearTh & ixNearRw;
hold on; set(gca, 'FontSize', 14); axis off;
plot(Y1(~ixNear,1), Y1(~ixNear,2), '.', 'Color', clrFar, 'MarkerSize', 8);
plot(Y1(ixNear,1), Y1(ixNear,2), '.', 'Color', clrNear, 'MarkerSize', 8);
plot(Y2(ind,1), Y2(ind,2), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
title('cloud-hab: both');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');

%%

figure; set(gcf, 'color', 'w');
trgAng = 135;
ixNear = B2.thetaGrps == trgAng;
ixNear1 = B1.thetaGrps == trgAng;

clrNear1 = clrNear(end:-1:1);
clrFar1 = clrFar(end:-1:1);
clrNearh = [0.6 0.04 0.1];
clrFarh = [0.8 0.7 0.7];
mn = min([Y2; Yh; Y1]); mx = max([Y2; Yh; Y1]);

subplot(2,2,1);
hold on; set(gca, 'FontSize', 14); axis off;
plot(Y2(~ixNear,1), Y2(~ixNear,2), '.', 'Color', clrFar, 'MarkerSize', 8);
plot(Y2(ixNear,1), Y2(ixNear,2), '.', 'Color', clrNear, 'MarkerSize', 8);
title('observed');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');
xlim([mn(1) mx(1)]); ylim([mn(2) mx(2)]);

subplot(2,2,2);
hold on; set(gca, 'FontSize', 14); axis off;
% plot(Y2(ixNear,1), Y2(ixNear,2), '.', 'Color', clrNear, 'MarkerSize', 2);
% plot(Yh(ixNear,1), Yh(ixNear,2), '.', 'Color', clrNearh, 'MarkerSize', 2);
[bp2, mu2, sig2] = tools.gauss2dcirc(Y2(ixNear,:), 3);
[bph, muh, sigh] = tools.gauss2dcirc(Yh(ixNear,:), 3);
plot(mu2(1), mu2(2), '.', 'Color', clrNear, 'MarkerSize', 15);
plot(bp2(1,:), bp2(2,:), '-', 'Color', clrNear, 'LineWidth', 3);
plot(muh(1), muh(2), '.', 'Color', clrNearh, 'MarkerSize', 15);
plot(bph(1,:), bph(2,:), '-', 'Color', clrNearh, 'LineWidth', 3);
title('hypothesis and observed');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');
xlim([mn(1) mx(1)]); ylim([mn(2) mx(2)]);

subplot(2,2,3);
hold on; set(gca, 'FontSize', 14); axis off;
plot(Yh(~ixNear,1), Yh(~ixNear,2), '.', 'Color', clrFarh, 'MarkerSize', 8);
plot(Yh(ixNear,1), Yh(ixNear,2), '.', 'Color', clrNearh, 'MarkerSize', 8);
title('hypothesis');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');
xlim([mn(1) mx(1)]); ylim([mn(2) mx(2)]);

subplot(2,2,4);
hold on; set(gca, 'FontSize', 14); axis off;
plot(Y1(~ixNear1,1), Y1(~ixNear1,2), '.', 'Color', clrFar1, 'MarkerSize', 8);
plot(Y1(ixNear1,1), Y1(ixNear1,2), '.', 'Color', clrNear1, 'MarkerSize', 8);
title('intuitive');
axis on;
set(gca,'xtick',[],'ytick',[]);
xlabel('Nul_1'); ylabel('Nul_2');
xlim([mn(1) mx(1)]); ylim([mn(2) mx(2)]);
