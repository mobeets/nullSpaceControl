
% dts = io.getDates(false);
% dts = {'20130528', '20130527', '20130612', '20131212'};
% dts = {'20131212'};
% dts = setdiff(io.getDates(false), io.getDates);
% dts = io.getDates(false, true, {'Jeffy'});
% dts = {'20131205'};
% dts = dts(io.getMonkeyDateInds(dts, 'J'));

dts = io.getDates(false);
isDebug = false;
doSave = true;
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
opts.meanBinSz = 100; % smoothing for mean
opts.varBinSz = 100; % bin size for running var
opts.maxTrialSkip = 10; % max change that we can still count as one group
opts.minGroupSize = 100; % want at least N consecutive trials
opts.behavNm = 'trial_length'; % 'progress'
opts.lastBaselineTrial = 50;

% actual one used
% DATADIR = getpref('factorSpace', 'data_directory')
% fnm = fullfile(DATADIR, 'sessions', 'goodTrials_trialLength.mat')
% d = load(fnm)
% opts = d.opts;

% NOTE: can we use angular error?

behNm = opts.behavNm;
if strcmp(opts.behavNm, 'trial_length')
    behNm = 'acquisition time (normalized)';
elseif strcmp(opts.behavNm, 'angErrorAbs')
    behNm = 'Abs. angular cursor error';
end
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

objs = [];
for ii = 1:numel(dts)
    dtstr = dts{ii};
    if ~isDebug
        try
            cd ~/code/bciDynamics;
            D = io.loadData(dtstr, false, false);
%             D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan, ...
%                 'REMOVE_INCORRECTS', true));
            cd ~/code/nullSpaceControl;
        catch
            warning(['Could not load ' dtstr]);
            continue;
        end
    end    
    B = D.blocks(2);
    xs = B.trial_index;
    if strcmpi(opts.behavNm, 'trial_length') && ~isfield(B, 'trial_length')
        B.trial_length = nan(size(B.trial_index));
        axs = unique(xs);
        for jj = 1:numel(axs)
            ix = B.trial_index == axs(jj);
            B.trial_length(ix) = sum(ix);
        end
    elseif strcmpi(opts.behavNm, 'progress') && ~isfield(B, 'progress')
        cd ~/code/bciDynamics;
        B.progress = tools.getProgress([], B.pos, B.trgpos, [], B.vel);
        cd ~/code/nullSpaceControl;
    end
    ys = B.(opts.behavNm);
    if strcmpi(opts.behavNm, 'progress')
        ys = -ys;
    end
%     [isGood, ixs, xsb, ysb, ysv] = behav2.plotThreshTrials(xs, ys, opts);
    obj = behav2.plotThreshTrials2(xs, ys, opts);
    objs = [objs; obj];
    xsb = obj.xsb;
    ysb = obj.ysSmoothMeanNorm;    
    ysv = obj.ysSmoothVarNorm;
    ixs = {obj.ix};
    isGood = obj.isGood;
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
    if sum(ixs{1}) > 0
        plot([min(xsb(ixs{1})) max(xsb(ixs{1}))], [yl(2) yl(2)], ...
            'r-', 'LineWidth', lw);
    end
    xlabel('trial #');
    ylabel(['Mean of ' behNm]);
    ylim(yl);
    xlim([min(xs) max(xs)]);
    set(gca, 'YTick', [0 0.5 1.0]);
    set(gca, 'LineWidth', lw);
    
    figs.setPrintSize(gcf, popts);
    if all(isGood)
        chcFldr = goodDir;
    else
        chcFldr = badDir;
    end
    if doSave
        export_fig(gcf, fullfile(chcFldr, [dts{ii} '_mean.pdf']));
    else
        export_fig(gcf, 'plots/tmp_mean.pdf');
    end

    fig2 = plot.init(FontSize);
    plot(xsb, ysv, 'k-', 'LineWidth', lw);
    plot([min(xsb) max(xsb)], [opts.varThresh opts.varThresh], 'k--', ...
        'LineWidth', lw);
    if sum(ixs{1}) > 0
        plot([min(xsb(ixs{1})) max(xsb(ixs{1}))], [yl(2) yl(2)], ...
            'r-', 'LineWidth', lw);
    end
    xlabel('trial #');
    ylabel(['Var of ' behNm]);
    ylim(yl);
    xlim([min(xs) max(xs)]);
    set(gca, 'YTick', [0 0.5 1.0]);
    set(gca, 'LineWidth', lw);
    
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

save(fullfile(baseDir, ['goodTrials_' opts.behavNm '.mat']), 'Trs', 'opts');

%%

lw = 1;
xmx = 1010;
ymx = 8;
plot.init;
for ii = 1:numel(objs)
    subplot(6, 7, ii); hold on;
    obj = objs(ii);
    xsb = obj.xsb; xsb = xsb - min(xsb);
%     ysb = obj.ysSmoothMeanNorm;
    ysb = (45/1000)*obj.ysSmoothMean;
    ix = obj.ix;
    
    clr = 'k';
    if ~obj.isGood
        clr = 0.8*ones(3,1);
    end
    
%     plot([0 xmx], [opts.muThresh opts.muThresh], ...
%         '-', 'Color', 0.8*ones(3,1), 'LineWidth', lw);
%     yl = [0 1.01];
%     set(gca, 'YTick', [0 0.5 1.0]);

    plot(xsb(1:end-10), ysb(1:end-10), '-', 'Color', clr, 'LineWidth', lw);
%     plot(xsb(ix), ysb(ix), 'r-', 'LineWidth', lw);
    
    yl = [0 ymx];
    if sum(ix) > 0
        plot([min(xsb(ix)) max(xsb(ix))], [yl(2) yl(2)], ...
            'r-', 'LineWidth', lw);
    end
%     xlabel('Trial #');
%     ylabel(['Mean of ' behNm]);
    set(gca, 'YTick', [0 ymx]);
    ylim(yl);
    xlim([min(xsb) max(xsb)]);
    set(gca, 'LineWidth', lw);
    set(gca, 'XTick', [500]);
    xlim([0 xmx]);
    title(dts{ii});
end
