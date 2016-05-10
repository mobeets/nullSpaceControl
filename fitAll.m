% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'habitual', 'cloud-hab', 'mean shift', 'mean shift 2'};
% nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline'};

hypopts = struct();% struct('nBoots', 3);
popts = struct();
lopts = struct();
fldr = fullfile('plots', 'all', 'tmp');

dts = io.getAllowedDates();
for ii = 5%1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
%     
%     [~, rotThetas] = pred.meanShiftFit(D);
%     Z = pred.sameCloudFit(D, struct('rotThetas', -rotThetas));
%     D.hyps = pred.addPrediction(D, 'prune-rot', Z);
% 
%     D = pred.nullActivity(D);
%     D = score.scoreAll(D);
    
    [~, inds] = sort({D.hyps.name});
%     inds = 2:numel(D.hyps);
    figure;
    subplot(1,2,1); plot.barByHypQuick(D, D.hyps(inds), 'errOfMeans', 'se');
    subplot(1,2,2); plot.barByHypQuick(D, D.hyps(inds), 'covError', 'se');
    figure;
    subplot(1,2,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
    subplot(1,2,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');
end



