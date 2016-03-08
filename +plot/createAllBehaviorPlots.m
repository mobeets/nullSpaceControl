
params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360, ...
    'REMOVE_INCORRECTS', false);
ccaFcn = @(ys) tools.canoncorr_r(ys{1}, ys{2});
normFcn = @(y) norm(nanmean(y));
varFcn = @(y) norm(nanvar(y));

dts = io.getDates();

nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'};
fcns = {[], [], [], [], [], []};
collapseTrials = [true true true true true true];
nm = '-';

% nms = {{'YN', 'YR'}, {'YN', 'YR'}};
% fcns = {ccaFcn, ccaFcn};
% collapseTrials = [false true];
% nm = '-CCA';

% nms = {{'Y1', 'Y2'}, 'progress'};
% fcns = {ccaFcn, []};
% collapseTrials = [true, true];

nms = {'trial_length', 'progress', 'Y', 'Y', {'YN2', 'progress'}, {'YR2', 'YN2'}};
fcns = {[], [], normFcn, varFcn, ccaFcn, ccaFcn};
collapseTrials = [true, true, true, false, false, false];

blockInd = 0;
% grpName = '';
% grpName = 'targetAngle';
grpName = 'thetaGrps';
% binSz = 500; ptsPerBin = 40;
% binSz = 150; ptsPerBin = 50;
binSz = 150; ptsPerBin = 10;

close all;

for ii = 10%10:numel(dts)
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
    B = D.blocks(1);
    NB = B.fDecoder.NulM2;
    RB = B.fDecoder.RowM2;
    YN = Y*NB;
    YR = Y*RB;
    D.trials.Y = Y;
    D.trials.YN = YN;
    D.trials.YR = YR;
    
    B = D.blocks(2);
    NB2 = B.fDecoder.NulM2;
    RB2 = B.fDecoder.RowM2;
    YN2 = Y*NB2;
    YR2 = Y*RB2;
    D.trials.YN2 = YN2;
    D.trials.YR2 = YR2;
    
    D.trials.YnewR = Y*(NB*NB')*RB2;
    D.trials.YnewN = Y*(NB*NB')*NB2;
    
    D.trials.YsameR = Y*(RB*RB')*RB2;
    D.trials.YsameN = Y*(RB*RB')*NB2;
    
    D.trials.Y1 = Y(:,1);
    D.trials.Y2 = Y(:,2);

    [Y,X,N, figs] = plot.allBehaviorsByTrial(D, nms, blockInd, grpName, ...
        binSz, ptsPerBin, collapseTrials, fcns, true);
%     for jj = 1:numel(figs)
%         saveas(figs(jj).fig, ...
%             fullfile('plots', 'behaviorByTrial', [figs(jj).name nm]), 'png');
%     end
end
