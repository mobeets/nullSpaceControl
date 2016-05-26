
dts = io.getAllowedDates();
nms = {'true', 'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
    'unconstrained', 'mean shift'};
nms = {'true', 'cloud-raw', 'unconstrained', 'uniform'};
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps');
lopts = struct('postLoadFcn', @io.makeImeDefault);
popts = struct();

dtstr = dts{4};
D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
nhyps = numel(D.scores);

%%
nbs = 10:10:100;
% nbs = [25 50 100 250 500 1000 2000 5000];
nbs = [25 50 75 100 150 200];
nbs = [20 3000];
for ii = 1:numel(nbs)
    D = score.scoreAll(D, hypopts, struct('nbins', nbs(ii)));
end

%%

plot.init;
for jj = 1%1:8
%     subplot(2,4,jj); hold on;
    scs = nan(nhyps, numel(nbs));
    for ii = 2:nhyps
%         tmp = [D.scores(2:end,ii).histErrByCol];
%         scs(ii,:) = tmp(jj,:);
        scs(ii,:) = [D.scores(2:end,ii).histErr];
        plot(nbs, scs(ii,:)./[D.scores(2:end,2).histErr], 'LineWidth', 3);
    end
    xlabel('nbins');
    ylabel('hist error');
    title([dtstr]);% ' ' num2str(jj)]);
    legend({D.score(2:end).name});%, 'Location', 'BestInside');
    legend boxoff;
end
