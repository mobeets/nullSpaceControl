
params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360, ...
    'REMOVE_INCORRECTS', false);
ccaFcn = @(y) tools.canoncorr_r(y{1}, y{2});
normFcn = @(y) norm(nanmean(y));
varFcn = @(y) norm(nanvar(y));
diffFcn = @(y) norm(nanmean(y{1} - y{2}));
% dts = io.getDates();
dts = {'20120525', '20120601', '20120709', '20131212'};
% dts = setdiff(dts, dts0);

nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'};
fcns = {[], [], [], [], [], []};
collapseTrials = [true true true true true true];
nm = '-';

nms = {'spd'};
fncs = {[]};
collapseTrials = [true];

% nms = {'progress', 'trial_length'};
% fcns = {[], []};
% collapseTrials = [true true];
% nm = '-';

% nms = {{'YN2', 'YR2'}, 'YN2', 'YN2', 'YR2', 'YR2'};
% fcns = {ccaFcn, varFcn, normFcn, varFcn, normFcn};
% collapseTrials = [false false false false false];
% nm = '-CCA';

% nms = {{'YN2', 'YR2'}};
% fcns = {ccaFcn};
% collapseTrials = [false];
% nm = '-CCA';

% nms = {{'YN1', 'YR1'}, {'YN2', 'YR2'}, 'progress', 'trial_length'};
% fcns = {ccaFcn, ccaFcn, [], []};
% collapseTrials = [false, false, true, true];

grpNames = {''};%, 'targetAngle', 'thetaGrps'};
doSave = false;

% binSz = 500; ptsPerBin = 40;
% binSz = 150; ptsPerBin = 50;
binSz = 100; ptsPerBin = 4;

blockInd = 0;

% dts = {'20120525'};

% close all;
ths = cell(numel(dts),1);
for ii = 1:numel(dts)
    for jj = 1:numel(grpNames)
        grpName = grpNames{jj};
%         close all;
        dtstr = dts{ii};
        outdir = fullfile('plots', 'behaviorAndHypotheses', dtstr);
%         outdir = fullfile('plots', 'behaviorAndHypotheses', 'behavior');
        D = io.quickLoadByDate(dtstr, params, false);
        D.trials = tools.concatBlocks(D);
        [Y,X,N,fits] = plot.createBehaviorPlots(D, blockInd, grpName, nms, ...
            binSz, ptsPerBin, collapseTrials, fcns, doSave, nm, outdir);
        th = cell2mat(arrayfun(@(ii) cellfun(@(f) f(end), fits{ii}(:,2)), ...
            1:numel(fits), 'uni', 0));
        th(th >= max(D.blocks(2).trial_index)) = nan;
        ths{ii} = th;
    end
end
% ths = cell2mat(ths);
% save(fullfile('data', ['behavioralAsymptotes_' grpName '.mat']), 'ths', 'dts', 'nms')
