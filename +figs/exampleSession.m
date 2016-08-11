function [D, nms] = exampleSession(dirNm, dtEx)

    X = load(fullfile('data', 'fits', dirNm, [dtEx '.mat'])); D = X.D;
    nms = {D.hyps.name};
    
    % rescore to rotate with PCA
    hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16', ...
        'obeyBounds', true, 'boundsType', 'spikes');
    D = score.scoreAll(rmfield(rmfield(D, 'score'), 'scores'), hypopts);    

end
