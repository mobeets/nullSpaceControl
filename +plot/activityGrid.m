function activityGrid(dtstr, grpNames, popts)
    if nargin < 2 || isempty(grpNames)
        grpNames = {'', 'targetAngle', 'thetaGrps'};
    end
    if nargin < 3 || isempty(popts)
        popts = struct('doSave', false);
    end

    ccaFcn = @(y) tools.canoncorr_r(y{1}, y{2});
%     normFcn = @(y) norm(nanmean(y));
%     varFcn = @(y) norm(nanvar(y));
%     diffFcn = @(y) norm(nanmean(y{1} - y{2}));
    innerNorm = @(y) arrayfun(@(ii) norm(y(ii,:)), 1:size(y,1));
    normFcn2 = @(y) nanmean(innerNorm(y));
    propFcn = @(y) nanmean(innerNorm(y{1})./(innerNorm(y{1}) + innerNorm(y{2})));
    propVarFcn = @(y) nanvar(innerNorm(y{1})./(innerNorm(y{1}) + innerNorm(y{2})));    

    nms = {'progress', {'YR', 'YN'}, {'YR', 'YN'}, {'YR', 'YN'}, 'YR', 'YN'};
    fcns = {[], ccaFcn, propFcn, propVarFcn, normFcn2, normFcn2};
    fcnNms = {'', 'cca(YR,YN)', 'norm_mean YR/(YR+YN)', 'norm_var YR/(YR+YN)', '||YR||', '||YN||'};
    collapseTrials = [true false true true true true];
    fignm = '-CCA';
    binSz = 100; ptsPerBin = 4; blockInd = 0;    

    params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360, ...
        'REMOVE_INCORRECTS', true);
    D = io.quickLoadByDate(dtstr, params, struct('doRotate', false));
    D.trials = tools.concatBlocks(D);
    
    for jj = 1:numel(grpNames)
        grpName = grpNames{jj};        
        [Y,X,N,fits,popts] = plot.createBehaviorPlots(D, blockInd, ...
            grpName, nms, binSz, ptsPerBin, collapseTrials, fcns, ...
            fcnNms, popts);
    end

end
