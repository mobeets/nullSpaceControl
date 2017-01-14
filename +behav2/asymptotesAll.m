
% dts = io.getDates(false);
dts = {'20130528', '20130527', '20130612', '20131212'};
% dts = {'20131212'};
% dts = setdiff(io.getDates(false), io.getDates);
% dts = io.getDates(false, true, {'Jeffy'});
dts = {'20131205'};
% dts = dts(io.getMonkeyDateInds(dts, 'J'));

isDebug = false;
doSave = false;
popts = struct('width', 6, 'height', 6, 'margin', 0.125);

%% set up directories for saving

dirName = 'behavAsymps';
if doSave
    baseDir = fullfile('plots', dirName);
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
else
    baseDir = 'plots';
    goodDir = 'plots';
    badDir = goodDir;
end

%%

FontSize = 26;
lw = 3;

% fit opts
opts = struct();
opts.muThresh = 0.5;
opts.varThresh = 0.5;
opts.trialsInARow = 10;
opts.groupEvalFcn = @numel; % longest group of consecutive trials
opts.minGroupSize = 100; % want at least 150 consecutive trials
opts.meanBinSz = 150; % smoothing for mean
opts.varMeanBinSz = 150; % smoothing for mean before var
opts.varBinSz = 100; % bin size for running var
opts.behavNm = 'trial_length'; % 'progress'
% opts.behavNm = 'angErrorAbs';

% NOTE: can we use angular error?

behNm = opts.behavNm;
if strcmp(opts.behavNm, 'trial_length')
    behNm = 'acquisition time (normalized)';
elseif strcmp(opts.behavNm, 'angErrorAbs')
    behNm = 'Abs. angular cursor error';
end

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

% extra bin sizes to display
% binSzs = [1 100];
% binSzsV = [1 50 150];
binSzs = [];
binSzsV = [];

for ii = 1:numel(dts)
    dtstr = dts{ii};
    if ~isDebug
        try
            D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan, ...
                'REMOVE_INCORRECTS', true));
        catch
            warning(['Could not load ' dtstr]);
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
        warning(['Not enough trials for ' dtstr]);
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

    fig1 = plot.init(FontSize);
    
    plot(xsb, ysb, 'k-', 'LineWidth', lw);
    plot([min(xsb) max(xsb)], [opts.muThresh opts.muThresh], 'k--', ...
        'LineWidth', lw);
%     plot(xsb(ixs{1}), ysb(ixs{1}), 'r-', 'LineWidth', lw);
    yl = [0 1.01];
    plot([min(xsb(ixs{1})) max(xsb(ixs{1}))], [yl(2) yl(2)], ...
        'r-', 'LineWidth', lw);
    xlabel('trial #');
    ylabel(['Mean of ' behNm]);
    ylim(yl);
    xlim([min(xs) max(xs)]);
    set(gca, 'YTick', [0 0.5 1.0]);
    set(gca, 'LineWidth', lw);
    
    for jj = 1:numel(binSzs)
        opts2 = opts;
        opts2.meanBinSz = binSzs(jj);
        [~, ~, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts2);
        plot(xsb, ysb, '-', 'Color', [0.7 0.7 0.7]/sqrt(jj));
    end
    figs.setPrintSize(gcf, popts);
    if doSave
        export_fig(gcf, fullfile(chcFldr, [dts{ii} '_mean.pdf']));
    else
        export_fig(gcf, 'plots/tmp_mean.pdf');
    end

    [isGood, ixs, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts);
    fig2 = plot.init(FontSize);
    plot(xsb, ysv, 'k-', 'LineWidth', lw);
    plot([min(xsb) max(xsb)], [opts.varThresh opts.varThresh], 'k--', ...
        'LineWidth', lw);
    plot([min(xsb(ixs{1})) max(xsb(ixs{1}))], [yl(2) yl(2)], ...
        'r-', 'LineWidth', lw);
    xlabel('trial #');
    ylabel(['Var of ' behNm]);
    ylim(yl);
    xlim([min(xs) max(xs)]);
    set(gca, 'YTick', [0 0.5 1.0]);
    set(gca, 'LineWidth', lw);

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
    figs.setPrintSize(gcf, popts);
    if doSave
        export_fig(gcf, fullfile(chcFldr, [dts{ii} '_var.pdf']));
    else
        export_fig(gcf, 'plots/tmp_var.pdf');
        if isDebug
            break;
        end
    end
end

save(fullfile(baseDir, 'goodTrials_angErr.mat'), 'Trs', 'opts');
