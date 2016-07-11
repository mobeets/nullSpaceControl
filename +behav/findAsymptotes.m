
params = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
dts = io.getDates();

nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'};
fcns = {[], [], [], [], [], []};
collapseTrials = [true true true true true true];
nm = '-';

grpName = 'targetAngle';
binSz = 100; ptsPerBin = 10;
blockInd = 0;

ths = cell(numel(dts),1);
for ii = 1%:numel(dts)
    dtstr = dts{ii};
    D = io.quickLoadByDate(dtstr, params);
    D.trials = tools.concatBlocks(D);
    [X,Y,N,fits] = plot.createBehaviorPlots(D, blockInd, grpName, nms, ...
        binSz, ptsPerBin, collapseTrials, fcns);
    th = cell2mat(arrayfun(@(ii) cellfun(@(f) f(end), fits{ii}(:,2)), ...
        1:numel(fits), 'uni', 0));
    th(th >= max(D.blocks(2).trial_index)) = nan;
    ths{ii} = th;
end

% ths = cell2mat(ths);
% save(fullfile('data', ['behavioralAsymptotes_' grpName '.mat']), ...
%     'ths', 'dts', 'nms')

% thsS
% ths0S
