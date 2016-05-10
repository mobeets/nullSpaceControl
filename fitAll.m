% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'habitual', 'cloud-hab', 'unconstrained'};
% nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline'};

hypopts = struct();% struct('nBoots', 3);
popts = struct();
lopts = struct();
fldr = fullfile('plots', 'all', 'tmp');

dts = io.getAllowedDates();
for ii = 3%1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    
%     [~, rotThetas] = pred.meanShiftFit(D);
%     Z = pred.sameCloudFit(D, struct('rotThetas', -rotThetas));
%     D.hyps = pred.addPrediction(D, 'prune-rot', Z);
    
    nns = [0.1 0.2 0.3 0.4];
%     nns = [0.9 1.0 1.1 1.2];
%     nns = [];
%     nns = [0.3 0.4 0.5 0.6];
%     nns = [0.025 0.05 0.075 0.1];
    for jj = 1:numel(nns)
        nn = nns(jj);
        copts = struct('boundsThresh', nn);
        Z = pred.uncContFit(D, copts);
        D.hyps = pred.addPrediction(D, ['unc-' num2str(nn)], Z);
%         Z = pred.meanShiftFit(D, copts);
%         D.hyps = pred.addPrediction(D, ['mean s-' num2str(nn)], Z);
%         Z = pred.habContFit(D, copts);
%         D.hyps = pred.addPrediction(D, ['hab-' num2str(nn)], Z);
%         Z = pred.sameCloudFit(D, copts);
%         D.hyps = pred.addPrediction(D, ['prune-' num2str(nn)], Z);
    end

    D = pred.nullActivity(D);
    D = score.scoreAll(D);
    
%     inds = ismember({D.hyps.name}, {'true', 'habitual', 'pruning', 'hab-0.1', 'prune-0.1'});
%     inds = [2 4 6];
    [~, inds] = sort({D.hyps.name});
%     inds = [2 10 8];
%     inds = 2:numel(D.hyps);
    figure;
    subplot(1,2,1); plot.barByHypQuick(D, D.hyps(inds), 'errOfMeans', 'se');
    subplot(1,2,2); plot.barByHypQuick(D, D.hyps(inds), 'covError', 'se');
    figure;
    subplot(1,2,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
    subplot(1,2,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');
end



