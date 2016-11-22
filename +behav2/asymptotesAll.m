
dts = io.getDates(false);
% dts = setdiff(io.getDates(false), io.getDates);
% dts = io.getDates(false, true, {'Jeffy'});

%%

baseDir = fullfile('plots', 'behavVarProg');
goodDir = fullfile(baseDir, 'good');
badDir = fullfile(baseDir, 'bad');
if exist(goodDir, 'dir')
    rmdir(goodDir, 's');
end
mkdir(goodDir);
if exist(badDir, 'dir')
    rmdir(badDir, 's');
end
mkdir(badDir);

%%

opts = struct();
opts.muThresh = 0.5;
opts.varThresh = 0.5;
opts.trialsInARow = 10;
opts.groupEvalFcn = @numel; % longest group of consecutive trials
opts.minGroupSize = 150; % want at least 150 consecutive trials
opts.meanBinSz = 150; % smoothing for mean
opts.varMeanBinSz = 100; % smoothing for mean before var
opts.varBinSz = 100; % bin size for running var
opts.behavNm = 'progress';

% dts = {'20131205', '20120525', '20160810'};
% dts = {'20131125', '20131204', '20131205', '20131211', '20131212', '20131218'};

% close all;

% dne = {'20130528', '20130614', '20130619'};
% goods = {'20131125', '20131204', '20131205', '20131208', ...
%     '20131211', '20131212', '20131218'};
% bads = {'20130527', '20130612', '20131124', '20131214', '20131215'};

% '20131125'
% '20131204'
% '20131205'
% '20131211'
% '20131212'
% '20131218'

% '20160329'
% '20160714'
% '20160722'
% '20160726'
% '20160727'
% '20160810'

Xs = cell(numel(dts),1);
Ys = cell(numel(dts),1);
Vs = cell(numel(dts),1);
Trs = nan(numel(dts),4);
isGoods = nan(numel(dts),1);

isDebug = false;

for ii = 1:numel(dts)
    dtstr = dts{ii};
    if ~isDebug
        try
            D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan));
        catch
            continue;
        end
    end
    B = D.blocks(2);
    xs = B.trial_index;
    ys = B.(opts.behavNm);
    if strcmpi(opts.behavNm, 'progress')
        ys = -ys;
    end
    [isGood, ixs, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts);
    if numel(ysb) == 0
        continue;
    end
    Xs{ii} = xsb;
    Ys{ii} = ysb;
    Vs{ii} = ysv;
    if ~isempty(xsb(ixs{1}))
        tmn = min(xsb(ixs{1}));
        tmx = max(xsb(ixs{1}));
    else
        tmn = nan; tmx = nan;
    end    
    isGoods(ii) = all(isGood);
    Trs(ii,:) = [str2num(dtstr) tmn tmx all(isGood)];
    [str2num(dtstr) min(xsb(ixs{1})) max(xsb(ixs{1}))]

    plot.init;
    subplot(2,1,1); hold on;
    plot(xsb, ysb, 'k-');
    plot([min(xsb) max(xsb)], [opts.muThresh opts.muThresh], 'k--');
    plot(xsb(ixs{1}), ysb(ixs{1}), 'r-');
    xlabel('trial #');
    ylabel(opts.behavNm);
    title(dtstr);
    ylim([0 1.5]);
    
    binSzs = [20 100 200];
    for jj = 1:numel(binSzs)
        opts2 = opts;
        opts2.meanBinSz = binSzs(jj);
        [~, ~, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts2);
        plot(xsb, ysb, '-', 'Color', [0.7 0.7 0.7]/sqrt(jj));
    end

    [isGood, ixs, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts);
    subplot(2,1,2); hold on;
    plot(xsb, ysv, 'k-');
    plot([min(xsb) max(xsb)], [opts.varThresh opts.varThresh], 'k--');
    xlabel('trial #');
    ylabel(['var(' opts.behavNm ')']);
    ylim([0 1.5]);

    binSzsV = [50 150];
    for jj = 1:numel(binSzsV)
        opts2 = opts;
        opts2.varBinSz = binSzsV(jj);
        [~, ~, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts2);
        plot(xsb, ysv, '-', 'Color', [0.7 0.7 0.7]/sqrt(jj));
    end
    
    if all(isGood)
        chcFldr = goodDir;
        pos = [600 (ii-1)*20 600 600];
    else
        chcFldr = badDir;
        pos = [0 (ii-1)*20 600 600];
    end
    set(gcf, 'Position', pos);
    if isDebug
        saveas(gcf, 'plots/tmp.png');
        break;
    else
        saveas(gcf, fullfile(chcFldr, [dts{ii} '.png']));
    end
end

% save(fullfile(baseDir, 'goodTrials.mat'), 'Trs', 'opts');
