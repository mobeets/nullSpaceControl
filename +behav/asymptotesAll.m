
% dts = io.getDates();
dts = io.getAllowedDates();
grpNm = 'targetAngle';
opts = struct('binSz', 100, 'ptsPerBin', 10);
nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'};

thsByGrp = cell(numel(dts),1);
ths = cell(numel(dts),1);
for ii = 1%:numel(dts)
    [thsByGrp{ii}, grps] = behav.asymptotesByDt(dts{ii}, nms, grpNm, opts);
    ths{ii} = behav.asymptotesByDt(dts{ii}, nms, '', opts);
end

%%

inds = ismember(nms, {'progress', 'trial_length'});
plot.init;
behav.asymptotesShow(thsByGrp{1}(:,inds), ths{1}(inds), nms(inds), grps);
