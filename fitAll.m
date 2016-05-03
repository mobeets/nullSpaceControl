clrW = [200 200 200];
clrG = [112 191 65];
clrY = [255 211 40];
clrO = [243 144 25];
clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'habitual', 'cloud-hab'};
% nms = {'habitual', 'cloud-hab'};
nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
        'unconstrained', 'minimum', 'baseline'};
hypopts = struct();
popts = struct();
fldr = fullfile('plots', 'all', 'tmp');

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, [], nms, popts, [], hypopts);
    
%     opts = struct('decoderNm', 'fDecoder', 'fitInLatent', true);
%     Z = pred.minEnergyFit(D, opts);
%     D.hyps = pred.addPrediction(D, 'baseline-factor', Z);    
%     D = pred.nullActivity(D, hypopts);
%     D = score.scoreAll(D);

    fig = figure; plot.errorByKin(D.hyps(2:end), 'errOfMeansByKin', clrs);
    title(D.datestr);
    saveas(fig, fullfile(fldr, [D.datestr '-meanErr']), 'png');
    fig = figure; plot.errorByKin(D.hyps(2:end), 'covErrorByKin', clrs);
    title(D.datestr);
    saveas(fig, fullfile(fldr, [D.datestr '-covErr']), 'png');
    
    fig = figure; plot.covError(D.hyps(2:end), D.datestr, 'covError');
    title(D.datestr);
    saveas(fig, fullfile(fldr, [D.datestr '-avgCovErr']), 'png');
    
    fig = figure; plot.errOfMeans(D.hyps(2:end), D.datestr);
    title(D.datestr);
    saveas(fig, fullfile(fldr, [D.datestr '-avgMeanErr']), 'png');
end
