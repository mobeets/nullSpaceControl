
D = io.quickLoadByDate('20120601');
B1 = D.blocks(1);
B2 = D.blocks(2);
NB1 = B1.fDecoder.NulM2;
RB1 = B1.fDecoder.RowM2;
NB2 = B2.fDecoder.NulM2;
RB2 = B2.fDecoder.RowM2;

%% dependence on theta

B = B2;
NB = NB2;

Y = B.latents*NB;
xs = B.thetas;
gs = B.thetaGrps;

[Y_A,Y_B,r,U,V,stats] = canoncorr(Y, [cosd(xs) sind(xs)]);

grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));
figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 14);

for ii = 1:numel(grps)
    ix = grps(ii) == gs;
    plot(U(ix,1), U(ix,2), 'k.', 'Color', clrs(ii,:));
    [bp, muhat, sighat] = tools.gauss2dcirc(U(ix,:));
%     plot(bp(1,:), bp(2,:), '-', 'Color', clrs(ii,:), 'LineWidth', 3);
    plot(muhat(1), muhat(2), 'ko', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 15);    
    
end


%% raw column correlations with theta

B = B2;
NB = NB2;

xs = B.thetas;
gs = B.thetaGrps;
X = [cosd(xs) sind(xs)];
Y = B.latents*NB;
r = [];
for ii = 1:size(Y,2)
    [~,~,r(ii,:),~,~,~] = canoncorr(Y(:,ii), X);
end
r

%% covariance/correlation of YN/YR

B = B2;
NB = NB2;
RB = RB2;

YN = B.latents*NB;
YR = B.latents*RB;
C = corr(YN, YR);
% C = corr(YN);

figure; set(gcf, 'color', 'w');
colormap(cbrewer('div', 'RdBu', 21));
imagesc(C);
axis off;
caxis([-1 1]);
colorbar;

%% dependence on YR

B = B2;
NB = NB2;
RB = RB2;

YN = B.latents*NB;
YR = B.latents*RB;
[Y_A,Y_B,r,U,V,stats] = canoncorr(YR, YN);

for ii = 1:size(YR,2)
    figure; set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 14);
    
    plot(U(:,ii), V(:,ii), '.');
%     plot(U(:,ii), V(:,ii), '.');
%     for jj = 1:size(YN,2)
%         plot(YR(:,ii), YN(:,jj), '.');
%     end
end

