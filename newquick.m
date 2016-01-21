%% overview

% 1. load and filter data
% 2. load and prep decoding params (calls simplifyKalman)
% 3. make predictions for the five hypotheses
% 4. calculate mean activity in null space of shuffle basis
% 5. calculate errors from true activity in null space

%% load and prepare data

D = io.loadDataByDate('20120601');
D.params = io.loadParams(D);
D.blocks = io.getDataByBlock(D);
D = io.addDecoders(D);

%% make predictions

ii = 1;
D.hyps(ii).name = 'observed';
D.hyps(ii).latents = D.blocks(2).latents;

ii = 2;
D.hyps(ii).name = 'dummy';
D.hyps(ii).latents = pred.dummyFit(D);

ii = 3;
D.hyps(ii).name = 'minimum';
D.hyps(ii).latents = pred.minFireFit(D);

ii = 4;
D.hyps(ii).name = 'baseline';
D.hyps(ii).latents = pred.baseFireFit(D);

ii = 5;
D.hyps(ii).name = 'unconstrained';
D.hyps(ii).latents = pred.uncContFit(D);

ii = 6;
D.hyps(ii).name = 'habitual';
D.hyps(ii).latents = pred.habContFit(D);

ii = 7;
D.hyps(ii).name = 'volitional';
D.hyps(ii).latents = pred.volContFit(D);

%% calculate mean activity in null space of shuffle basis

D = pred.nullActivity(D);

%% assess errors in hypotheses

D = score.scoreAll(D);
[D.hyps.errOfMeans]

%% visualize

% Plot Actual vs. Predicted, Map1->Map2, for each null column of B2

% Plot error of means

% Plot covariance ratios
