%% choose dates

badDts = {'20130528', '20130614', '20130619', '20131124', '20131215'};

dts = io.getDates();
dts = dts(~ismember(dts, badDts));

% beh = load('data/asymptotes/byTargetAngle.mat');
% dts = beh.dts;
% [Dts, PrtNum, ~, PrtType, ~, ~] = io.importPatrickLearningMetrics();
% Dts = arrayfun(@num2str, Dts, 'uni', 0);
% ixOld = ismember(Dts, dts);
% ixBad = ismember(Dts, badDts);
% ixValid = strcmp(PrtType, 'within-manifold') & PrtNum == 1;
% dts = Dts(~ixOld & ixValid & ~ixBad);

%% set params

opts = struct('binSz', 100, 'ptsPerBin', 10);
% nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
%     'trial_length', 'isCorrect'};
nms = {'progress', 'trial_length'};
inds = ismember(nms, {'progress', 'trial_length'});
bind = 2;

%% fit by session

ths = cell(numel(dts),1);
for ii = 1:numel(dts)    
    ths{ii} = behav.asymptotesByDt(dts{ii}, nms, '', opts, bind);
    [dts{ii} ': ' num2str(ths{ii})]
    plotnm = fullfile('plots', 'behavioralAsymptotes', [dts{ii} '.png']);
    set(gcf, 'Position', [0 0 1000 400]);
    set(gcf, 'PaperPositionMode', 'auto');
    saveas(gcf, plotnm);
    continue;
end

%% fit by group within session

grpNm = 'targetAngle';
% grpNm = 'thetaActualGrps';

thsByGrp = cell(numel(dts),1);
for ii = 1:numel(dts)
    dts{ii}
    [thsByGrp{ii}, grps, D] = behav.asymptotesByDt(dts{ii}, nms, grpNm, opts, bind);
end

%% save fits

fnm = 'data/asymptotes/newDts.mat';
if exist(fnm, 'file')
    error('File already exists.');
end
% save(fnm, 'ths', 'thsByGrp', 'nms', 'dts', 'opts', 'grps');
save(fnm, 'ths', 'nms', 'dts', 'opts');

%% load saved asymptotes

beh = load('data/asymptotes/byTargetAngle.mat');
beh2 = load('data/asymptotes/byThetaActualGrps.mat');

ths = cell2mat(beh2.ths); ths = ths(:,2);
ths1 = [cellfun(@(b) nanmedian(b(:,2)), beh2.thsByGrp) ...
    cellfun(@(b) nanmedian(b(:,2)), beh.thsByGrp)];

%% visualize asymptotes by session

lbls = {'ths', 'med(ths-thetaActualGrps)', 'med(ths-targetAngle)'};
th = [ths ths1(:,1) ths1(:,2)];
plot.init;
bar(th);
legend(lbls)
set(gca, 'XTick', 1:numel(beh.dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('asymptote (trial #)');

%% visualize all asymptotes

for ii = 1:numel(dts)
    inds = ismember(nms, {'progress', 'trial_length'});
    plot.init;
    behav.asymptotesShow(thsByGrp{ii}(:,inds), ths{ii}(inds), ...
        nms(inds), grps);
end
