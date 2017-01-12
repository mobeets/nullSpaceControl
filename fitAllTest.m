
% nms = {'unconstrained', 'cloud', 'habitual', 'uncontrolled-uniform'};
nms = {'baseline'};
hypopts = struct('nBoots', 0, 'obeyBounds', true, ...
    'boundsType', 'spikes', 'scoreGrpNm', 'thetaActualGrps', ...
    'fitInLatent', false, 'addSpikeNoise', true);

lopts = struct('postLoadFcn', @io.makeImeDefault);
% lopts = struct('postLoadFcn', @io.splitIntuitiveBlock);
% lopts = struct();
popts = struct();
pms = struct();
dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
end
