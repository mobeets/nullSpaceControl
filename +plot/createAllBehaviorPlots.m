
params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360, ...
    'REMOVE_INCORRECTS', false);
ccaFcn = @(ys) tools.canoncorr_r(ys{1}, ys{2});

dts = io.getDates();

nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'}
%     {'YN', 'YR'}, {'YN', 'YR'}};
fcns = {[], [], [], [], [], []}%, ccaFcn, ccaFcn};
collapseTrials = [true true true true true true]% true false];

% nms = {{'YN', 'YR'}};
% fcns = {ccaFcn};
% collapseTrials = [false];

% nms = {'angError', 'progress'};
% fcns = {[], []};
% collapseTrials = [true true];

blockInd = 0;
grpName = 'targetAngle';
% binSz = 500; ptsPerBin = 40;
% binSz = 150; ptsPerBin = 50;
binSz = 150; ptsPerBin = 10;

close all;

for ii = 4%:numel(dts)
    dtstr = dts{ii};
    D = io.quickLoadByDate(dtstr, params);
    
    % update fields
    D.trials.progressOrth = nan(size(D.trials.progress));
    for t = 1:numel(D.trials.progress)
        vec2trg = D.trials.vec2target(t,:);
        vec2trgOrth(1) = vec2trg(2);
        vec2trgOrth(2) = -vec2trg(1);
        movVec = D.trials.movementVector(t,:);
        D.trials.progressOrth(t) = -(movVec*vec2trgOrth'/norm(vec2trg));
    end
    D.trials.angErrorAbs = abs(D.trials.angError);
    Y = D.trials.latents;
    B = D.blocks(2);
    NB = B.fDecoder.NulM2;
    RB = B.fDecoder.RowM2;
    YN = Y*NB;
    YR = Y*RB;
    D.trials.YN = YN;
    D.trials.YR = YR;

    [Y,X,N, figs] = plot.allBehaviorsByTrial(D, nms, blockInd, grpName, ...
        binSz, ptsPerBin, collapseTrials, fcns, true);
    for jj = 1:numel(figs)
        saveas(figs(jj).fig, ...
            fullfile('plots', 'behaviorByTrial', figs(jj).name), 'png');
    end
end
