
F = io.loadRawDataByDate('20120601'); % '20131205');
ps = F.simpleData.decodedPositions;
trg = F.simpleData.targetLocations;
trgs = unique(trg, 'rows');

%%

sz = 80;
csz = 100;
close all;
figure;
for ii = 1:5%numel(ps)
    p = ps{ii};
    for jj = 1:size(p,1)
        clf;
        hold on;
        title([F.datestr ' - trial #' num2str(ii)]);
        scatter(trgs(:,1), trgs(:,2), sz, 'b', 'filled'); % all targs
        scatter(trg(ii,1), trg(ii,2), sz, 'r', 'filled'); % cur targ
        scatter(p(1,1), p(1,2), sz, 'k+'); % origin
        scatter(p(jj,1), p(jj,2), csz, 'k'); % cursor
        xlim([-150 150]); ylim([100 450]);
        axis square; axis off; set(gcf, 'color', 'w');
        pause(1e-3);
    end
    pause(0.5);
end

%% distribution of trial lengths, by target angle

tms = arrayfun(@(ii) size(ps{ii},1), 1:numel(ps));
gls = F.simpleData.targetAngles;
allgls = sort(unique(gls));

mxtm = 150;
figure; set(gcf, 'color', 'w');
for ii = 1:numel(allgls)
    subplot(numel(allgls), 1, ii); hold on;
    box off; set(gca, 'FontSize', 14);
    ys = tms(gls == allgls(ii) & tms' < mxtm);
    hist(ys, linspace(0, mxtm, 30));
    plot([median(ys) median(ys)], ylim, 'r', 'LineWidth', 3);
    xlim([0 mxtm]);
    ylabel(['\theta = ' num2str(allgls(ii))]);
end

%% angular error by target angle

% D = io.loadDataByDate('20120601');
ix0 = D.trials.block_index == 1;% & D.trials.trial_index > 200;
gls = D.trials.targetAngle;
allgls = sort(unique(gls));
figure; set(gcf, 'color', 'w');
mx = 200;
for ii = 1:numel(allgls)
    subplot(numel(allgls), 1, ii); hold on;
    box off; set(gca, 'FontSize', 14);
    
    ix = gls == allgls(ii) & ix0;
    ys = D.trials.angError(ix);
    hist(ys, linspace(-mx, mx, 40));
%     hist(D.trials.spd(ix));
    plot([nanmedian(ys) nanmedian(ys)], ylim, 'r', 'LineWidth', 3);
    xlim([-mx mx]);
    
    ylabel(['\theta = ' num2str(allgls(ii))]);
end

%% traces of activity before/after kinematics

% D = io.loadDataByDate('20120601');
% D.trials = io.makeTrials(D);
% ix0 = D.trials.block_index == 2;
% gls = D.trials.thetaGrps;


B = D.blocks(2);
gls = B.thetaGrps;

NB = B.fDecoder.RowM2;
[u,s,v] = svd(B.latents*NB);
NB = NB*v;

% [u,s,v] = svd(B.latents);
% NB = v;

allgls = sort(unique(gls(~isnan(gls))));

figure; hold on;
hold on; set(gcf, 'color', 'w'); box off; set(gca, 'FontSize', 14);
clrs = cbrewer('div', 'RdYlGn', numel(allgls));
for ii = 1:numel(allgls)
    ix = gls == allgls(ii);% & ix0;
    trind = B.trial_index(ix);
    tmind = B.time(ix);
%     figure; hold on;    

    vs = nan(numel(trind), 201);
    for jj = 1:numel(trind)
        tr = trind(jj);
        tm = tmind(jj);
        ix1 = B.trial_index == tr;
        ix2 = (B.time >= tm - 100) & (B.time <= tm + 100);
        lts = B.latents(ix1&ix2,:)*NB;
        vals = lts(:,2);
% %         vals = arrayfun(@(ii) norm(lts(ii,:)), 1:size(lts,1));
        tms = B.time(ix1 & ix2) - tm;
%         plot(tms, vals, 'Color', [0.5 0.5 0.5]);
        vs(jj,tms + 101) = vals;
    end
    plot(-100:100, nanmean(vs), 'Color', clrs(ii,:), 'LineWidth', 3);
end
xlim([-20 20]);
xlabel('time aligned to \theta');
ylabel('norm');
title('norm(null)');
legend(arrayfun(@(g) num2str(g), allgls, 'uni', 0));

%% relationship between norm and angError for each kinematics

% D = io.loadDataByDate('20120601');
% D.trials = io.makeTrials(D);

fignm = '';

B = D.blocks(1);
gls = B.thetaGrps;
NB = D.blocks(1).fDecoder.RowM2;

% B = D.trials;
% gls = B.thetaGrps(B.block_index == 1);

allgls = sort(unique(gls(~isnan(gls))));
fig = figure; plot.subtitle(fignm);
for ii = 1:numel(allgls)
	subplot(3, 3, ii);
    hold on; set(gcf, 'color', 'w'); box off;
    set(gca, 'FontSize', 14);
    xlabel('angular error');
    ylabel(['\theta = ' num2str(allgls(ii))]);
    ix = gls == allgls(ii);% & ix0;
    xs = B.angError(ix);
    lts = B.latents(ix,:);%*NB;
%     lts = mean(lts);
%     vals = norm(lts)*ones(size(xs));
    vals = arrayfun(@(ii) norm(lts(ii,:)), 1:size(lts,1));
    plot(xs, vals, '.');
    plot(xlim, [mean(vals) mean(vals)], 'k', 'LineWidth', 3);
    xlim([-20 20]);
    ylim([0 10]);
    set(gca, 'YTick', 0:10);
end
% saveas(fig, ['plots/' fignm], 'png');
