% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'habitual', 'cloud-hab', 'cloud-raw'};
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
    
    nns = [0.2 0.3 0.4 0.5];
    for jj = 1:numel(nns)
        nn = nns(jj);
        copts = struct('boundsThresh', nn);
        Z = pred.sameCloudFit(D, copts);
        D.hyps = pred.addPrediction(D, ['cloud-' num2str(nn)], Z);
    end

    D = pred.nullActivity(D);
    D = score.scoreAll(D);
    
    inds = ~strcmp('cloud', {D.hyps.name});
    inds = [2 4 6];
%     inds = 2:numel(D.hyps);
    figure;
    subplot(1,2,1); plot.barByHypQuick(D, D.hyps(inds), 'errOfMeans', 'se');
    subplot(1,2,2); plot.barByHypQuick(D, D.hyps(inds), 'covError', 'se');
    figure;
    subplot(1,2,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
    subplot(1,2,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');
end



