

D = io.quickLoadByDate(1, struct('MAX_ANGULAR_ERROR', 360));

%%
D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));

%%

rotThetas = pred.findReaimingAnglesWithIntuitive(D);
D.hyps = pred.addPrediction(D, 'cloud-hab-rot', pred.sameCloudFit(D, ...
    0.35, 30, {}, {}, rotThetas));

D = pred.nullActivity(D);
D = score.scoreAll(D);

figure; set(gcf, 'color', 'w');
subplot(1,3,1); hold on;
plot.errOfMeans(D.hyps(2:end), D.datestr);
subplot(1,3,2); hold on;
plot.covError(D.hyps(2:end), D.datestr, 'covErrorOrient');
subplot(1,3,3); hold on;
plot.covError(D.hyps(2:end), D.datestr, 'covErrorShape');
