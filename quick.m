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
D = tools.rotateLatentsUpdateDecoders(D, false);

%% make predictions

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

D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
% D.hyps = pred.addPrediction(D, 'habitual + rotated', ...
%     pred.rotatedFit(D, pred.getHyp(D, 'habitual')));
D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));

%%

D.hyps = pred.addPrediction(D, 'volitional', pred.volContFit(D, true, 0));
% D.hyps = pred.addPrediction(D, 'volitional + rotated', ...
%     pred.rotatedFit(D, pred.getHyp(D, 'volitional')));
% D.hyps = pred.addPrediction(D, 'volitional + no precursor', ...
%     pred.volContFit(D, false, 0));

%%

% D.hyps = pred.addPrediction(D, 'volitional + 2PCsV2', ...
%     pred.volContFit(D, true, 1));
D.hyps = pred.addPrediction(D, 'volitional + 2PCs', ...
    pred.volContFit(D, true, 2));
% D.hyps = pred.addPrediction(D, 'volitional + 3PCs', ...
%     pred.volContFit(D, true, 3));
% D.hyps = pred.addPrediction(D, 'volitional + 4PCs', ...
%     pred.volContFit(D, true, 4));

%% calculate mean activity in null space of shuffle basis
%   and assess errors in hypotheses

D = pred.nullActivity(D);
D = score.scoreAll(D);
[D.hyps.errOfMeans]
figure; plot.errOfMeans(D.hyps(2:end), D.datestr);
% figure; plot.covRatio(D.hyps(2:end));

%% visualize

plot.plotAll(D, D.hyps(2:end), true, false, false);
% tmp(D, D.hyps(2:end));

%%

% figure; plot.errOfMeans(D.hyps(2:end));
% figure; plot.errOfMeans(F.hyps(2:end));
plot.plotHyp(F, pred.getHyp(F, 'volitional + 2PCs'));
plot.plotHyp(D, pred.getHyp(D, 'volitional + 2PCs'));

