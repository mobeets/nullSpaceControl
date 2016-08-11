
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16', ...
    'obeyBounds', true, 'boundsType', 'spikes');

dts = io.getDates();
for ii = 1:numel(dts)
    
    X = load(fullfile(baseDir, [dts{ii} '.mat'])); D = X.D;
    D = score.scoreAll(rmfield(rmfield(D, 'score'), 'scores'), hypopts);
    
end
