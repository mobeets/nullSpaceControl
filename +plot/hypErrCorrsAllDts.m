
dts = io.getAllowedDates();

%% learning

nkins = 8;
lrn = nan(numel(dts), nkins);
Lmax = nan(size(lrn));
Lbest = nan(size(lrn));
% vals = {'progress'}; sgns = [1];
vals = {'isCorrect', 'trial_length'}; sgns = [1 1];

for ii = 1:numel(dts)
    dtstr = dts{ii}
    if numel(vals) == 1
        [lrn(ii,:), Lmax(ii,:), Lbest(ii,:)] = plot.learningByKin(dtstr, vals);
    else
        lrn(ii,:) = plot.learningByKin(dtstr, vals, [], [], sgns);
    end
    close all;
end
fnm = ['data/fits/learning_' [vals{:}] '.mat'];
save(fnm, 'lrn', 'Lmax', 'Lbest')

%%

val = 'trial-length';
fnm = ['data/fits/learning_' val '.mat'];
load(fnm, 'lrn', 'Lmax', 'Lbest')

%%

[lrn, Lmax, Lbest] = plot.learningByKin(dtstr, {'isCorrect', 'trial_length'});
close all;

%% hyp scores

HsVol = [];
HsHab = [];
HsCld = [];
for ii = 1:numel(dts)
    dtstr = dts{ii}
%     nms = {'volitional', 'habitual', 'cloud-hab', 'cloud-raw'};
    nms = {'cloud-raw'};
    D = fitByDate(dtstr, [], nms, [], [], []);    
    HsHab = [HsHab D.hyps(2)];
%     HsCld = [HsCld D.hyps(3)];
%     HsVol = [HsVol D.hyps(4)];

end

%% gather errors

Hs = HsHab;
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
    plot(xs(ii,:), ys(ii,:), 'ko', 'MarkerFaceColor', clr);
end
xlabel(xlbl);
ylabel(ylbl);

%% plot errors vs. learning

xlbl = 'learning';
ylbl = 'error';
clrs = cbrewer('qual', 'Set2', size(xs,1));
figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 14);

% mnks = logical([1 1 0 0 0]);
vs = xs;
ws = Lmax;
assert(all(sign(ws(:)) == sign(ws(1)))); % all same sign
ws = ws*sign(ws(1));

rsq = [];
for ii = 1:size(vs,1)
    clr = clrs(ii,:);
    xc = ws(ii,:); yc = vs(ii,:);
%     xc = ws(mnks==(ii-1),:); yc = vs(mnks==(ii-1),:); xc = xc(:)'; yc = yc(:)';
    xc2 = [xc; ones(size(xc))];
    [b,bint,r,rint,stats] = regress(yc', xc2');
    rsq(ii,:) = [b(1) stats(1) stats(3)]; % slope, r-sq, p-val
    plot(xc, xc2'*b, '-', 'Color', clr, 'LineWidth', 3);
    plot(xc, yc, 'ko', 'Color', clr, 'MarkerFaceColor', clr);    
end
xlabel(xlbl);
ylabel(ylbl);
title('Lbest, cov orient error');

