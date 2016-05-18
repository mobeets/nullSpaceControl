
dtstr = '20120709';
nms = {'habitual', 'cloud-hab', 'cloud-raw', 'unconstrained'};
D = fitByDate(dtstr, [], nms);

%%

inds = 2:numel(D.hyps);
% inds = [3 4 8];
figure;
subplot(2,1,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
subplot(2,1,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');

figure; plot.meanErrorByKinByCol(D, pred.getHyp(D, 'pruning'));

%%

opts = struct('splitKinsByFig', true, 'doHistOnly', true);
grps = D.blocks(2).thetaGrps;
NB = D.blocks(2).fDecoder.NulM2;
Y1 = pred.getHyp(D, 'observed').latents;
Y2 = pred.getHyp(D, 'pruning').latents;

ix = 1:size(grps,1);
ix = grps == 225;
Y1 = Y1(ix,:); Y2 = Y2(ix,:); grps = grps(ix,:);
plot.marginals(Y1*NB, Y2*NB, grps, [], opts);

