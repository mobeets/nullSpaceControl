%% overview

% 1. load and filter data
% 2. load and prep decoding params (calls simplifyKalman)
% 3. make predictions for the five hypotheses
% 4. calculate mean activity in null space of shuffle basis
% 5. calculate errors from true activity in null space

%% load and prepare data

D = io.loadDataByDate('20120601'); % 20120525 20120601
D.params = io.loadParams(D);
D.params.MAX_ANGULAR_ERROR = 360;
D.blocks = io.getDataByBlock(D);
D.blocks = pred.addTrainAndTestIdx(D.blocks);
D = io.addDecoders(D);
% D = tools.rotateLatentsUpdateDecoders(D);

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

%%

ii = 9;
D.hyps(ii).name = 'habitual';
D.hyps(ii).latents = pred.habContFit(D);

ii = 10;
D.hyps(ii).name = 'habitual - rotated';
D.hyps(ii).latents = pred.rotatedFit(D, D.hyps(9));

%%

ii = 11;
D.hyps(ii).name = 'volitional';
D.hyps(ii).latents = pred.volContFit(D, true);

ii = 12;
D.hyps(ii).name = 'volitional - rotated';
D.hyps(ii).latents = pred.rotatedFit(D, D.hyps(11));

ii = 13;
D.hyps(ii).name = 'volitional - no precursor';
D.hyps(ii).latents = pred.volContFit(D, false);

%%

close all;
% figure; plot.blkSummaryPredicted(D, D.hyps(1), false, true);
figure; plot.blkSummaryPredicted(D, D.hyps(11), true, false, true);
% figure; plot.blkSummaryPredicted(D, D.hyps(14), false, true);
figure; plot.blkSummaryPredicted(D, D.hyps(9), true, false, true);

%% calculate mean activity in null space of shuffle basis
%   and assess errors in hypotheses

D = pred.nullActivity(D);
D = score.scoreAll(D);
[D.hyps.errOfMeans]
% [D.hyps.errOfMeansFull]
% [D.hyps.covRatio]

%% visualize

close all;
doRotate = true;
doTranspose = true;
ext = '';
if doRotate
    ext = [ext '_rot'];
end
if doTranspose
    ext = [ext '_kin'];
end
fnm = @(nm) fullfile('plots', ['fits_' D.datestr ext], nm);

% Plot Actual vs. Predicted, Map1->Map2, for each null column of B2
for ii = 1:numel(D.hyps)
    fig = figure; plot.blkSummaryPredicted(D, D.hyps(ii), doRotate, ...
        false, doTranspose);
    saveas(fig, fullfile(fnm([D.hyps(ii).name '-mean'])), 'png');
    fig = figure; plot.blkSummaryPredicted(D, D.hyps(ii), doRotate, ...
        true, doTranspose);
    saveas(fig, fullfile(fnm([D.hyps(ii).name '-pts'])), 'png');
end

% Plot error of means
fig = figure; plot.errOfMeans(D.hyps(2:end));
saveas(fig, fullfile(fnm(['errOfMeans'])), 'png');

% Plot covariance ratios
