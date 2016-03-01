dts = io.getDates();
dt = dts{2};
% E = fitByDate(dt, [false false false], ...
%     struct('MIN_ANGULAR_ERROR', 40, 'MAX_ANGULAR_ERROR', 360));
D = io.quickLoadByDate(dt, struct('MAX_ANGULAR_ERROR', 360));
close all

%%

F = D;
{F.hyps.name}
[F.hyps.errOfMeans; F.hyps.covErrorShape; F.hyps.covErrorOrient]
F = E;
[F.hyps.errOfMeans; F.hyps.covErrorShape; F.hyps.covErrorOrient]

%%

% close all
vs = cell(numel(dts),1);
for ii = 1%:numel(dts)
    dt = dts{ii}
%     D = io.quickLoadByDate(ii);
%     a = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
%     b = D.params.START_SHUFFLE;
%     c = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));
%     [dt ': ' num2str(b-a+1) ' ' num2str(c-a+1)]
    D = io.quickLoadByDate(ii, ...
        struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 40));
    figure;
    vs{ii} = plot.satExpCursorProgess(D.blocks(2), 'targetAngle', 0.85);%, b-a+1);
    plot.subtitle(dt);
end

%%

