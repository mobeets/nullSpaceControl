% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'habitual', 'cloud-hab'};
% nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline'};

hypopts = struct();% struct('nBoots', 3);
popts = struct();
lopts = struct();
fldr = fullfile('plots', 'all', 'tmp');

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    
    Z = pred.sameCloudFit(D, struct('youIdiot', true));
    D.hyps = pred.addPrediction(D, 'pruning-real', Z);
%     
% %     nns = [20 40 60 80 100];
%     nns = [0.8 1.0 1.5 2.0];
% %     nns = [0.4 0.8 1.0 1.2 1.4];
% %     nns = [2 4 6];
%     for jj = 1:numel(nns)
%         nn = nns(jj);
%         curopts = struct('localThresh', nn);
%         Z = pred.habContFit(D, curopts);
%         D.hyps = pred.addPrediction(D, ['hab-' num2str(nn)], Z);
%     end

    D = pred.nullActivity(D);
    D = score.scoreAll(D);
    
    figure;
    subplot(1,2,1); plot.barByHypQuick(D, D.hyps(2:end), 'errOfMeans', 'se');
    subplot(1,2,2); plot.barByHypQuick(D, D.hyps(2:end), 'covError', 'se');
    figure;
    subplot(1,2,1); plot.errorByKin(D.hyps(2:end), 'errOfMeansByKin', [], 'se');
    subplot(1,2,2); plot.errorByKin(D.hyps(2:end), 'covErrorByKin', [], 'se');
end



