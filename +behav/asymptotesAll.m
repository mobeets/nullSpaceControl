
dts = io.getDates();
grpNm = 'targetAngle';
% grpNm = 'thetaActualGrps';
opts = struct('binSz', 100, 'ptsPerBin', 10);
% nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
%     'trial_length', 'isCorrect'};
nms = {'progress', 'trial_length'};

inds = ismember(nms, {'progress', 'trial_length'});
bind = 1;

thsByGrp = cell(numel(dts),1);
ths = cell(numel(dts),1);
for ii = 1:numel(dts)
    dts{ii}
%     [thsByGrp{ii}, grps, D] = behav.asymptotesByDt(dts{ii}, nms, grpNm, opts, bind);
    ths{ii} = behav.asymptotesByDt(dts{ii}, nms, '', opts, bind);
    continue;
    
    plot.init;
    behav.asymptotesShow(thsByGrp{ii}(:,inds), ths{ii}(inds), nms(inds), grps);
    
    vals = [nanmedian(thsByGrp{ii}(:,2)) ...
        min(D.blocks(bind).trial_index) max(D.blocks(bind).trial_index)];
    stls = {'--', 'k-', 'k-'};
    for jj = 1:numel(vals)
        plot(xlim, [vals(jj) vals(jj)], stls{jj});
    end
    title(dts{ii})
    saveas(gcf, 'plots/tmp.png');
    
    [ths{ii}(2) vals]
    disp('-----');
end

% save('data/asymptotes/byThetaActualGrps.mat', ...
%     'ths', 'thsByGrp', 'nms', 'dts', 'opts', 'grps');

%%

beh = load('data/asymptotes/byTargetAngle.mat');
beh2 = load('data/asymptotes/byThetaActualGrps.mat');

ths = cell2mat(beh2.ths); ths = ths(:,2);
ths1 = [cellfun(@(b) nanmedian(b(:,2)), beh2.thsByGrp) ...
    cellfun(@(b) nanmedian(b(:,2)), beh.thsByGrp)];

%%

lbls = {'ths', 'med(ths-thetaActualGrps)', 'med(ths-targetAngle)'};
th = [ths ths1(:,1) ths1(:,2)];
plot.init;
bar(th);
legend(lbls)
set(gca, 'XTick', 1:numel(beh.dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('asymptote (trial #)');

%%

for ii = 1:numel(dts)
    inds = ismember(nms, {'progress', 'trial_length'});
    plot.init;
    behav.asymptotesShow(thsByGrp{1}(:,inds), ths{1}(inds), nms(inds), grps);
end
