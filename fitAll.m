
% nms = {'true', 'habitual', 'cloud-hab'};
% nms = {'habitual', 'cloud-hab'};
nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
        'unconstrained', 'minimum', 'baseline'};

dts = io.getAllowedDates();
for ii = 1:5%1:numel(dts)
    dtstr = dts{ii}
    popts = struct('doSave', true, 'doSolos', false, ...
        'plotdir', fullfile('plots', 'all', dtstr, 'hypScores'), ...
        'doTimestampFolder', false);
    hypopts = struct();
    D = fitByDate(dtstr, [], nms, popts, [], hypopts);
    close all;
end
