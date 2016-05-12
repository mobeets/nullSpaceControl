% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'habitual', 'cloud-hab', 'unconstrained'};
% nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline'};

hypopts = struct('nBoots', 0);
lopts = struct('postLoadFcn', nan);
popts = struct();
fldr = fullfile('plots', 'all', 'tmp');

dts = io.getAllowedDates();
for ii = [1 2 4 5]%1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);

    Z1 = pred.fitByTargGrps(D, @pred.uncContFit, struct(), 'thetaGrps', 2, 1);
    D = pred.addAndScoreHypothesis(D, Z1, 'unc-trg-orth');
    Z2 = pred.fitByTargGrps(D, @pred.uncContFit, struct(), 'thetaGrps', 2, 2);
    D = pred.addAndScoreHypothesis(D, Z2, 'unc-trg-all');
    
    [~, inds] = sort({D.hyps.name});
%     inds = 2:numel(D.hyps);
%     figure;
%     subplot(1,2,1); plot.barByHypQuick(D, D.hyps(inds), 'errOfMeans', 'se');
%     subplot(1,2,2); plot.barByHypQuick(D, D.hyps(inds), 'covError', 'se');
    figure;
    subplot(1,2,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
    subplot(1,2,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');
    title(D.datestr);
%     figure; plot.errorByKin(D.hyps(inds), 'pctErrOfMeansByKin', [], 'se');
    
end



