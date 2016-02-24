%% overview

% 1. load and filter data
% 2. load and prep decoding params (calls simplifyKalman)
% 3. make predictions for the five hypotheses
% 4. calculate mean activity in null space of shuffle basis
% 5. calculate errors from true activity in null space

%% load and prepare data

dtstr = '20120601'; % 20120525 20120601 20131125 20131205
D = io.loadDataByDate(dtstr);
D.params = io.setFilterDefaults(D.params);
D.params.MAX_ANGULAR_ERROR = 360;
D.blocks = io.getDataByBlock(D);
D.blocks = pred.addTrainAndTestIdx(D.blocks);
D = io.addDecoders(D);
D = tools.rotateLatentsUpdateDecoders(D, true);

%% make predictions

% D = rmfield(D, 'hyps');
D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
% D.hyps = pred.addPrediction(D, 'volitional w/ 2Fs', ...
%     pred.volContFit(D, true, 2));
% D.hyps = pred.addPrediction(D, 'kNN', pred.kNNFit(D, 100, {'rs'}));
% D.hyps = pred.addPrediction(D, 'cloud min', pred.sameCloudFit(D));
% D.hyps = pred.addPrediction(D, 'cloud theta', pred.sameCloudFit(D, nan, 15));
% D.hyps = pred.addPrediction(D, 'vol w/ 2Fs', pred.volContFit(D, true, 2));
D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
% D.hyps = pred.addPrediction(D, 'cloud-vol', pred.volCloudFit(D, nan, nan));

% D.hyps = pred.addPrediction(D, 'regRowOnNul', pred.regRowOnNulFit(D));

% D.hyps = pred.addPrediction(D, 'cloud', pred.sameCloudFit(D, 0.35));
D = pred.nullActivity(D);
D = score.scoreAll(D);
% close all;
%%
figure; set(gcf, 'color', 'w');
subplot(1,3,1); hold on; plot.errOfMeans(D.hyps(2:end), D.datestr);
subplot(1,3,2); hold on; plot.covError(D.hyps(2:end), D.datestr, 'covErrorOrient');
subplot(1,3,3); hold on; plot.covError(D.hyps(2:end), D.datestr, 'covErrorShape');

%%

% ys = 0:5:60;
ys = -45:5:30;
for rotTheta = ys
    D.hyps = pred.addPrediction(D, ['cloud-hab-' num2str(rotTheta)], ...
        pred.sameCloudFit(D, 0.35, 30, {}, {}, rotTheta));
end
D = pred.nullActivity(D);
D = score.scoreAll(D);

%%

D.hyps = pred.addPrediction(D, 'cloud-hab-rot', ...
    pred.sameCloudFit(D, 0.35, 30, {}, {}, rs(:,2)));

%%

B1 = D.blocks(1);
B2 = D.blocks(2);
Y1 = B1.latents;
Y2 = B2.latents;
RB1 = B1.fDecoder.RowM2;
RB2 = B2.fDecoder.RowM2;
xs1 = B1.thetaGrps;
xs2 = B2.thetaGrps;

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
%%

figure; subplot(1,2,1);
plot.cursorMovementByBlock(D, '1');
subplot(1,2,2);
plot.cursorMovementByBlock(D, '2');

%%

% D = rmfield(D, 'hyps');
D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
D.hyps = pred.addPrediction(D, 'zero', pred.meanFit(D, 'zero'));
D.hyps = pred.addPrediction(D, 'best mean', pred.meanFit(D, 'best'));
D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));

%%

D.hyps = pred.addPrediction(D, 'minimum', pred.minFireFit(D));
D.hyps = pred.addPrediction(D, 'baseline', pred.baseFireFit(D));
D.hyps = pred.addPrediction(D, 'unconstrained', pred.uncContFit(D));

%%

D.hyps = pred.addPrediction(D, 'cloud', pred.sameCloudFit(D, 2));
D.hyps = pred.addPrediction(D, 'cloud min', pred.sameCloudFit(D));

%%

D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
% D.hyps = pred.addPrediction(D, 'habitual + rotated', ...
%     pred.rotatedFit(D, pred.getHyp(D, 'habitual')));

%%

D.hyps = pred.addPrediction(D, 'volitional', pred.volContFit(D, true, 0));
% D.hyps = pred.addPrediction(D, 'volitional + rotated', ...
%     pred.rotatedFit(D, pred.getHyp(D, 'volitional')));
% D.hyps = pred.addPrediction(D, 'volitional + no precursor', ...
%     pred.volContFit(D, false, 0));

%%

% D.hyps = pred.addPrediction(D, 'volitional + 2PCsV2', ...
%     pred.volContFit(D, true, 1));
D.hyps = pred.addPrediction(D, 'volitional w/ 2Fs', ...
    pred.volContFit(D, true, 2));
D.hyps = pred.addPrediction(D, 'volitional w/ 2FsB (s=5)', ...
    pred.volContFit(D, true, 2, 5));

%%

D.hyps = pred.addPrediction(D, 'volitional w/ 3Fs2b', ...
    pred.volContFit(D, true, 3));

% 
% D.hyps = pred.addPrediction(D, 'precursor + 2Fs', ...
%     pred.volContFit(D, true, 2));
% D.hyps = pred.addPrediction(D, '2Fs', ...
%     pred.volContFit(D, false, 2));

% D.hyps = pred.addPrediction(D, 'volitional + 2PCs v2', ...
%     pred.volContFit(D, true, 2));

% D.hyps = pred.addPrediction(D, 'volitional + 2PCs + noPre', ...
%     pred.volContFit(D, false, 2));
% D.hyps = pred.addPrediction(D, 'volitional + 3PCs', ...
%     pred.volContFit(D, true, 3));
% D.hyps = pred.addPrediction(D, 'volitional + 4PCs', ...
%     pred.volContFit(D, true, 4));

%% calculate mean activity in null space of shuffle basis
%   and assess errors in hypotheses

disp('-----');
D = pred.nullActivity(D);
D = score.scoreAll(D);
[D.hyps.errOfMeans]
[D.hyps.covErrorOrient]
[D.hyps.covErrorShape]
% [D.hyps(2).covError D.hyps(end).covError]

%%
figure; plot.errOfMeans(D.hyps(2:end), D.datestr);
% figure; plot.covRatio(D.hyps(2:end));
% figure; plot.covError(D.hyps(2:end), D.datestr);
figure; plot.covError(D.hyps(2:end), D.datestr, 'covErrorOrient');
figure; plot.covError(D.hyps(2:end), D.datestr, 'covErrorShape');

%% visualize

plot.plotAll(D, D.hyps(2:end), false, false, true);
% tmp(D, D.hyps(2:end));

%%

% figure; plot.errOfMeans(D.hyps(2:end));
% figure; plot.errOfMeans(F.hyps(2:end));
% plot.plotHyp(F, pred.getHyp(F, 'volitional + 2PCs'));
plot.plotHyp(D, pred.getHyp(D, 'cloud-hab'));

