
% nms = {'true', 'habitual', 'cloud-hab'};
% nms = {'habitual', 'cloud-hab'};
nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
        'unconstrained', 'minimum', 'baseline'};
% nms = {'zero', 'cloud-hab', 'minimum', 'baseline'};

popts = struct();
hypopts = struct();

dts = io.getAllowedDates();
for ii = 3%:5 %1:numel(dts)
    dtstr = dts{ii}        
    D = fitByDate(dtstr, [], nms, popts, [], hypopts);
    
    opts = struct('decoderNm', 'fDecoder', 'fitInLatent', true, ...
        'minType', 'minimum');
    Z = pred.minEnergyFit(D, opts);
    D.hyps = pred.addPrediction(D, 'min-factor', Z);
    
    opts = struct('decoderNm', 'fDecoder', 'fitInLatent', true);
    Z = pred.minEnergyFit(D, opts);
    D.hyps = pred.addPrediction(D, 'baseline-factor', Z);
    
    D = pred.nullActivity(D, hypopts);
    D = score.scoreAll(D);
    figure; plot.errorByKin(D.hyps(2:end), 'errOfMeansByKin');
end
