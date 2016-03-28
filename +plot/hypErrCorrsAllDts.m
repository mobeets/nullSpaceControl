
dts = io.getAllowedDates();

%% learning

nkins = 8;
lrn = nan(numel(dts), nkins);
Lmax = nan(size(lrn));
Lbest = nan(size(lrn));

for ii = 1:numel(dts)
    dtstr = dts{ii}
    [lrn(ii,:), Lmax(ii,:), Lbest(ii,:)] = plot.learningByKin(dtstr, ...
        {'trial_length'});
    close all;
end

%% hyp scores

Hs = [];
for ii = 1:numel(dts)
    dtstr = dts{ii}
    nms = {'cloud-hab'};
    D = fitByDate(dtstr, [], nms, [], [], []);
    Hs = [Hs D.hyps(2)];

end

%% gather errors

xs = cell2mat({Hs.errOfMeansByKin}');
zs = log([Hs.covErrorOrientByKin]');
ys = log([Hs.covErrorShapeByKin]');

%% correlate with one another

xlbl = 'mean error';
ylbl = 'log(cov shape error)';
zlbl = 'log(cov orient error)';

clrs = cbrewer('qual', 'Set2', size(xs,1));
figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 14);
for ii = 1:size(xs,1)
    clr = clrs(ii,:);
    plot(ys(ii,:), zs(ii,:), 'ko', 'MarkerFaceColor', clr);
end
xlabel(ylbl);
ylabel(zlbl);

%% plot errors vs. learning

xlbl = 'learning';
ylbl = 'error';
clrs = cbrewer('qual', 'Set2', size(xs,1));
figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 14);

vs = zs;
for ii = 1:size(vs,1)
    clr = clrs(ii,:);
    [~,ix] = sort(vs(ii,:));
    plot(Lmax(ii,ix), vs(ii,ix), 'ko-', 'MarkerFaceColor', clr);
end
xlabel(xlbl);
ylabel(ylbl);
title('Lmax, cov orient error');

