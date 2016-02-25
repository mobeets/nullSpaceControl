%% fit at all fixed rotation angles

% ys = 0:5:60; % 20131225
ys = -45:5:30; % 20120601
for rotTheta = ys
    D.hyps = pred.addPrediction(D, ['cloud-hab-' num2str(rotTheta)], ...
        pred.sameCloudFit(D, 0.35, 30, {}, {}, rotTheta));
end
D = pred.nullActivity(D);
D = score.scoreAll(D);

%% find the best per kinematics angle

xs = score.thetaCenters(8);
vs = [];
for rotTheta = ys
    hyp = pred.getHyp(D, ['cloud-hab-' num2str(rotTheta)]);
    vs = [vs; hyp.errOfMeansByKin];
end

rs = nan(size(vs,2), 2);
for ii = 1:size(vs,2)
    vs(:,ii) = vs(:,ii) - min(vs(:,ii));
    [~,ix] = min(vs(:,ii));
    rs(ii,:) = [xs(ii) ys(ix)];
end

D.hyps = pred.addPrediction(D, 'cloud-hab-rot', ...
    pred.sameCloudFit(D, 0.35, 30, {}, {}, rs(:,2)));

%% visualize alignment with intuitive activity in perturbed mapping

B1 = D.blocks(1);
B2 = D.blocks(2);
Y1 = B1.latents;
Y2 = B2.latents;
RB1 = B1.fDecoder.RowM2;
RB2 = B2.fDecoder.RowM2;
xs1 = B1.thetaGrps;
xs2 = B2.thetaGrps;

figure; imagesc(xs, ys, vs);
set(gca, 'XTick', xs);
set(gca, 'YTick', ys);
caxis([0 round(max(vs(:)))]);

figure; hold on; set(gcf, 'color', 'w'); axis off;
plot(0,0,'k+'); plot(0,0,'ko');
clrs = cbrewer('div', 'RdYlGn', numel(xs));
for ii = 1:size(rs,1)
    v1 = rs(ii,1) - 45;
    v2 = v1 + rs(ii,2) + 0.67;
    plot(cosd(v1), sind(v1), 'd', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    plot(cosd(v2), sind(v2), 'o', 'Color', clrs(ii,:));
    plot(cosd(v2), sind(v2), 'x', 'Color', clrs(ii,:));
    plot([cosd(v1) cosd(v2)], [sind(v1) sind(v2)], '--', 'Color', clrs(ii,:));

    ix1 = (xs1 == rs(ii,1));
    ix2 = (xs2 == rs(ii,1));
    Yv1 = nanmean(Y1(ix1,:)*RB1);
    Yv2 = nanmean(Y1(ix1,:)*RB2);
%     Yv2 = nanmean(Y2(ix2,:)*RB1);
    Yv1 = Yv1./(1.3*norm(Yv1));
    Yv2 = Yv2./(1.3*norm(Yv2));
    plot(Yv1(1), Yv1(2), 'ks', 'MarkerFaceColor', clrs(ii,:));
    plot(Yv2(1), Yv2(2), 'ko', 'MarkerFaceColor', clrs(ii,:));
    plot([Yv1(1) Yv2(1)], [Yv1(2) Yv2(2)], '-', 'Color', clrs(ii,:));
end
axis square;
title(D.datestr);

figure; subplot(1,2,1);
plot.cursorMovementByBlock(D, '1');
subplot(1,2,2);
plot.cursorMovementByBlock(D, '2');