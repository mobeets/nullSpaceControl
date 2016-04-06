function [Y,X,N,nms] = behaviorGrid(dtstr, grpNames, popts)
    if nargin < 2 || isempty(grpNames)
        grpNames = {'', 'targetAngle', 'thetaGrps'};
    end
    if nargin < 3 || isempty(popts)
        popts = struct('doSave', false);
    end

    nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
        'trial_length', 'isCorrect'}; fcns = []; fcnNms = {};
    collapseTrials = true(numel(nms),1);
    binSz = 100; ptsPerBin = 4; blockInd = 0;

    params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360, ...
        'REMOVE_INCORRECTS', false);
    D = io.quickLoadByDate(dtstr, params, struct('doRotate', false));
    D.trials = tools.concatBlocks(D);
    
    for jj = 1:numel(grpNames)
        grpName = grpNames{jj};        
        [Y,X,N,fits,popts] = plot.createBehaviorPlots(D, blockInd, ...
            grpName, nms, binSz, ptsPerBin, collapseTrials, fcns, ...
            fcnNms, popts);
    end

end
