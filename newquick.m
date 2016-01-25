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
D.blocks = pred.addTrainAndTestIdx(D.blocks);

%% make predictions

ii = 1;
D.hyps(ii).name = 'observed';
D.hyps(ii).latents = D.blocks(2).latents;

ii = 2;
D.hyps(ii).name = 'dumb zero';
D.hyps(ii).latents = pred.meanFit(D, 'zero');

ii = 3;
D.hyps(ii).name = 'dumb mean';
D.hyps(ii).latents = pred.meanFit(D, 'mean');

ii = 4;
D.hyps(ii).name = 'best dumb mean';
D.hyps(ii).latents = pred.meanFit(D, 'best');

ii = 5;
D.hyps(ii).name = 'no null';
D.hyps(ii).latents = pred.dummyFit(D); % same as dumb zero in null space

%%

ii = 6;
D.hyps(ii).name = 'minimum';
D.hyps(ii).latents = pred.minFireFit(D);

ii = 7;
D.hyps(ii).name = 'baseline';
D.hyps(ii).latents = pred.baseFireFit(D);

ii = 8;
D.hyps(ii).name = 'unconstrained';
D.hyps(ii).latents = pred.uncContFit(D);

ii = 9;
D.hyps(ii).name = 'habitual';
D.hyps(ii).latents = pred.habContFit(D);

ii = 10;
D.hyps(ii).name = 'volitional';
D.hyps(ii).latents = pred.volContFit(D, true);

ii = 11;
D.hyps(ii).name = 'rotated habitual';
D.hyps(ii).latents = pred.rotatedFit(D, D.hyps(9));

ii = 12;
D.hyps(ii).name = 'rotated volitional';
D.hyps(ii).latents = pred.rotatedFit(D, D.hyps(10));

ii = 13;
D.hyps(ii).name = 'volitional - no precursor';
D.hyps(ii).latents = pred.volContFit(D, false);

ii = 14;
D.hyps(ii).name = 'habitual, skip thetas';
D.hyps(ii).latents = pred.rotatedFit(D, D.hyps(9));


%% calculate mean activity in null space of shuffle basis

D = pred.nullActivity(D);

%% assess errors in hypotheses

D = score.scoreAll(D);
[D.hyps.errOfMeans]
% [D.hyps.errOfMeansFull]
% [D.hyps.covRatio]

%%

% close all;
clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];
figure; plot.blkSummary(D.blocks(2), [], [], true, true, clr1);
% figure; plot.blkSummary(F.blocks(2), [], [], true, true, clr2);

%% visualize

% close all;
fnm = @(nm) fullfile('plots', 'fits2', nm);

% Plot Actual vs. Predicted, Map1->Map2, for each null column of B2
for ii = 14:numel(D.hyps)
    H = D.hyps(ii);
    fig = figure;
    plot.blkSummaryPredicted;
    saveas(fig, fullfile(fnm([H.name ''])), 'png');
end

% Plot error of means
figure; plot.errOfMeans(D.hyps(2:end));

% Plot covariance ratios
