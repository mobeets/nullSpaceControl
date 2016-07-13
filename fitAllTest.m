
% nms = {'habitual', 'pruning', 'cloud', 'unconstrained', 'mean shift prune'};
% nms = {'unconstrained', 'habitual', 'pruning', 'cloud', ...
%     'mean shift prune', 'mean shift'};
% nms = {'habitual', 'pruning', 'pruning-1', 'cloud', 'cloud-og', ...
%     'voltional', 'mean shift prune', 'mean shift', 'unconstrained', ...
%     'baseline', 'minimum'};
nms = {'best-sample', 'habitual', 'pruning', 'cloud', 'unconstrained'};
nms = {'best-sample', 'habitual', 'cloud', 'cloud-sub'};
% nms = {'best-sample', 'habitual', 'cloud'};
% nms = {'best-sample', 'cloud'};

% nms = {'cheat', 'habitual', 'cloud', 'unconstrained', 'best-sample', ...
%     'gauss', 'condnrm', 'condnrmkin', 'condnrmrow'};

hypopts = struct('nBoots', 0, 'obeyBounds', false, ...
    'scoreGrpNm', 'thetaActualGrps');

loptsA = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, false, 1:2));
loptsB = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, false, 3:4));
loptsC = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, false, 5:6));
loptsD = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, false, 7:8));
loptsE = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, false, 1:4));
loptsF = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, false, 5:8));
lopts2 = struct('postLoadFcn', @(D) io.keepThingsIrrelevant(D, true));

% lopts = struct('postLoadFcn', nan);
lopts = struct('postLoadFcn', @io.makeImeDefault);
% lopts = struct('postLoadFcn', @(D) io.makeImeDefault(D, true));
% lopts = struct('postLoadFcn', @io.splitIntuitiveBlock);
% lopts = struct('postLoadFcn', @(D) io.splitIntuitiveBlock(D, 2, 0.5, true));
% lopts2 = struct('postLoadFcn', @(D) io.splitIntuitiveBlock(D, 2, 0.5, false));


popts = struct();
% popts = struct('plotdir', '', 'doSave', true, 'doTimestampFolder', false);
% pms = struct('MAX_ANGULAR_ERROR', 20);
pms = struct();

dts = io.getAllowedDates();
% dts2 = {'20120327', '20120331', '20131211', '20131212'};
% dts = {'20120303', '20120319', '20131218'};
% dts = [dts dts2];
% dts = sort(dts);
% dts = io.getDates();
% Ss = cell(numel(dts),1);

% figure(1); hold on;
% figure(2); hold on;
% figure(3); hold on;
% figure(4); hold on;

scs1 = cell(numel(dts),1);
scs0 = scs1;
for ii = 4%[4 5] %5:-1:1%1:numel(dts)
    dtstr = dts{ii}
%     popts.plotdir = ['plots/moreDts/' dtstr];

    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    plot.init;
    subplot(1,2,1); hold on;
    plot.errorByKin(D.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    subplot(1,2,2); hold on;
    plot.errorByKin(D.score(2:end), 'covErrorByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    continue;

%     DE = fitByDate(dtstr, pms, nms, popts, loptsE, hypopts);
%     plot.init; plot.errorByKin(DE.score(2:end), 'errOfMeansByKin'); title(D.datestr);
%     saveas(gcf, 'plots/tmp.png');
%     
%     DF = fitByDate(dtstr, pms, nms, popts, loptsF, hypopts);
%     plot.init; plot.errorByKin(DF.score(2:end), 'errOfMeansByKin'); title(D.datestr);
%     saveas(gcf, 'plots/tmp.png');
%     continue;

    DA = fitByDate(dtstr, pms, nms, popts, loptsA, hypopts);
    plot.init; plot.errorByKin(DA.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    
    DB = fitByDate(dtstr, pms, nms, popts, loptsB, hypopts);
    plot.init; plot.errorByKin(DB.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    
    DC = fitByDate(dtstr, pms, nms, popts, loptsC, hypopts);
    plot.init; plot.errorByKin(DC.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    
    DD = fitByDate(dtstr, pms, nms, popts, loptsD, hypopts);
    plot.init; plot.errorByKin(DD.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    
    D2 = fitByDate(dtstr, pms, nms, popts, lopts2, hypopts);
    plot.init; plot.errorByKin(D2.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    continue;
    
%     save(['data/fits/splitIntuitive/' dtstr], 'D');

    figure(1); hold on;
%     subplot(1,5,ii); hold on;
    plot.barByHypQuick(D.score(2:end), 'errOfMeans'); title(D.datestr);
    figure(2); hold on;
%     subplot(1,5,ii); hold on;
    plot.errorByKin(D.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    figure(3); hold on;
%     subplot(1,5,ii); hold on;
    plot.barByHypQuick(D2.score(2:end), 'errOfMeans'); title(D.datestr);
    figure(4); hold on;
%     subplot(1,5,ii); hold on;
    plot.errorByKin(D2.score(2:end), 'errOfMeansByKin'); title(D.datestr);
    
    saveas(gcf, 'plots/tmp.png');
    continue;
    
    
    subplot(2,2,4); hold on;
    mcols = cellfun(@nanmean, {D.score(2:end).errOfMeansByKinByCol}, 'uni', 0);
    mcols = cell2mat(mcols');
    plot(mcols(1,:), mcols(3,:), '.');
    mx = max(max(mcols([1 3],:)));
    xlim([0 mx]); ylim(xlim);
    plot(xlim, ylim, 'k--');
    set(gca, 'XTick', 0:0.5:mx); set(gca, 'YTick', 0:0.5:mx);
    xlabel('habitual mean error');
    ylabel('cloud mean error');
    subplot(2,2,3); hold on;
%     plot.barByHyp(mean(mcols,2), {D.score(2:end).name}); title(D.datestr);
    plot.barByHypQuick(D.score(2:end), 'covError'); title(D.datestr);
    ylabel('errOfMeans_avgByCol');
    
    saveas(gcf, 'plots/tmp.png');
    continue;
    
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    D2 = fitByDate(dtstr, pms, nms, popts, lopts2, hypopts);
    save(['data/fits/randHalfPert/allInt_' dtstr], 'D');
    save(['data/fits/randHalfPert/randHalfPert_' dtstr], 'D2');
    
    if ii < 6
        figA = 1; figB = 2; jj = ii;
    else
        figA = 3; figB = 4; jj = ii-5;
    end
    figure(figA); subplot(1,5,jj); hold on;
    plot.barByHypQuick(D.score(2:end), 'errOfMeans'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    figure(figB); subplot(1,5,jj); hold on;
    plot.barByHypQuick(D2.score(2:end), 'errOfMeans'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    continue;
    
    inds = ismember({D.score.name}, {'habitual', 'pruning', 'cloud', 'unconstrained'});
    scs1{ii} = {D.score(inds).errOfMeansByKin};
    X = load(['data/fits/savedFull/' dtstr '.mat']); E = X.D;
    inds = ismember({E.score.name}, {'habitual', 'pruning', 'cloud', 'unconstrained'});
    scs0{ii} = {E.score(inds).errOfMeansByKin};
    
    continue;
    
    figure;
    subplot(2,2,1); hold on;
    plot.barByHypQuick(D.score(inds), 'errOfMeans'); title(D.datestr);
    ylim([0 3]);
    subplot(2,2,2); hold on;
    plot.errorByKin(D.score(inds), 'errOfMeansByKin'); title(D.datestr);
    ylim([0 5]);
    subplot(2,2,3); hold on;
    X = load(['data/fits/savedFull/' dtstr '.mat']); E = X.D;
    inds = ismember({E.score.name}, {'habitual', 'pruning', 'cloud', 'unconstrained'});
    plot.barByHypQuick(E.score(inds), 'errOfMeans'); title(D.datestr);
    ylim([0 3]);
    subplot(2,2,4); hold on;
    plot.errorByKin(E.score(inds), 'errOfMeansByKin'); title(D.datestr);
    ylim([0 5]);
    
    saveas(gcf, 'plots/tmp.png');
    continue;
    
%     ps = [10 20 30 45];
%     Zs = cell(numel(ps),1); nmsc = cell(size(Zs));
%     for jj = 1:numel(ps)
%         custopts = hypopts;
%         custopts.thetaTol = ps(jj);
%         Zs{jj} = pred.habContFit(D, custopts);
%         nmsc{jj} = ['hab-' num2str(ps(jj))];
%     end
%     D = pred.addAndScoreHypothesis(D, Zs, nmsc);
%     [~, inds] = sort({D.hyps.name});
    figure; plot.barByHypQuick(D.score(2:end), 'errOfMeans'); title(D.datestr);
    saveas(gcf, 'plots/tmp.png');
    
    continue;
    
    [~, inds] = sort({D.hyps.name});
    figure;
    subplot(2,1,1); plot.barByHypQuick(D.score(inds), 'errOfMeans');
    subplot(2,1,2); plot.barByHypQuick(D.score(inds), 'kdeErr');
    continue;
    
%     ps = [5 10 15 20 30 40 50];
%     Zs = cell(numel(ps),1); nmsc = cell(size(Zs));
%     for jj = 1:numel(ps)
%         custopts = struct('obeyBounds', false, 'minDist', nan, ...
%             'thetaTol', ps(jj), 'kNN', 1, 'thetaNm', 'thetaActuals');
%         Zs{jj} = pred.habContFit(D, custopts);
%         nmsc{jj} = ['habitual-' num2str(ps(jj))];
%     end
%     D = pred.addAndScoreHypothesis(D, Zs, nmsc);
%     
%     Z1 = pred.sameCloudFit(D, ...
%         struct('minDist', nan, 'thetaTol', 5, 'kNN', 1, ...
%         'thetaNm', 'targetAngle'));
%     Z2 = pred.sameCloudFit(D, ...
%         struct('minDist', nan, 'thetaTol', 5, 'kNN', 1, ...
%         'thetaNm', 'thetaActualGrps'));
%     Z3 = pred.sameCloudFit(D, ...
%         struct('minDist', nan, 'thetaTol', 5, 'kNN', 1, ...
%         'thetaNm', 'thetaGrps'));
%     D = pred.addAndScoreHypothesis(D, {Z1, Z2, Z3}, {'pruning-ang', ...
%         'pruning-actgrp', 'pruning-thgrp'});
    
    inds = 2:numel(D.hyps);
%     inds = [2 3 4 5 6 8 9];
%     [~, inds] = sort({D.hyps.name});
%     figure; plot.errorByKin(D.score(inds), 'errOfMeansByKin');
%     figure; plot.errorByKin(D.score(inds), 'covErrorByKin');
    
    figure;
%     plot.barByHypQuick(D.score(inds), 'errOfMeans');
    plot.errorByKin(D.score(inds), 'errOfMeansByKin');
    title(dtstr);
    continue;
    
    plot.init;
    hypopts.nullCols = nan;
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    subplot(3,3,1); hold on;
    plot.barByHypQuick(D.score(2:end), 'errOfMeans');
    title([dtstr ' all']);
        
    for jj = 1:8
        hypopts.nullCols = jj;
        D = rmfield(D, 'score');
        D = rmfield(D, 'scores');
        D = score.scoreAll(D, hypopts);
        subplot(3,3,jj+1); hold on;
        plot.barByHypQuick(D.score(2:end), 'errOfMeans');
        title([dtstr ' col ' num2str(jj)]);
    end
    continue;
    
%     Ss{ii} = D.score;
%     continue;
% 
%     E = D;
%     D.hyps(1).latents = D.hyps(3).latents; % fit devs from pruning
%     D = rmfield(rmfield(D, 'score'), 'scores');
%     D = score.scoreAll(D, hypopts);
%     
%     
%     Ss2{ii} = D.score;
%     
%     
%     
%     S1 = {D.score(2:4).errOfMeansByKin};
%     S2 = {E.score(2:4).errOfMeansByKin};
%     plot.init;
%     for jj = [1 3]
%         xs = S1{jj};
%         ys = S2{jj} - S2{2}; % deviation from pruning's scores
%         plot(xs, ys, 'o');
%     end
%     xlabel('difference from pruning');
%     ylabel('error predicting observed');
%     legend({'habitual', 'cloud'});% legend boxoff;
%     title(dtstr);
%     v = axis; lo = min(v(1:2:end)); up = max(v(2:2:end)); axis([lo up lo up]);
%     
%     continue;
%     
%     figure; plot.barByHypQuick(D.score(2:end), 'errOfMeans');
% %     figure; plot.barByHypQuick(D.score(2:end), 'histErr');
%     
%     gs = D.blocks(2).(hypopts.scoreGrpNm);
%     grps = sort(unique(gs));
%     scs = nan(numel(grps), numel(D.hyps)-1);
%     for jj = 1:numel(grps)
%         grps(jj)
%         ix = grps(jj) == gs;
%         Y = D.hyps(1).nullActivity.zNull(ix,:);
%         Yhs = cellfun(@(obj) obj.zNull(ix,:), ...
%             {D.hyps(2:end).nullActivity}, 'uni', 0);
%         scs(jj,:) = score.kdeError(Y, Yhs, 'all');
%     end
%     Scs{ii} = scs;
%     
%     plot.init;
%     for jj = 1:size(scs,2)
%         plot(grps, scs(:,jj), '-o', 'LineWidth', 3);
%     end
%     legend({D.hyps(2:end).name});
%     legend boxoff;
%     
%     plot.init; plot.barByHyp(mean(scs), {D.score(2:end).name});
%     
% %     scs2{ii} = score.kdeError(Y, Yhs);
% %     plot.init; plot.barByHyp(scs2{ii}, {D.score(3:end).name});
% %     ylabel('base kde'); title(dtstr);
%     
%     continue;

%     ps = 1;
%     Zs = cell(numel(ps),1); nmsc = cell(size(Zs));
%     for jj = 1:numel(ps)
%         custopts = struct('minDist', nan, 'thetaTol', nan, 'kNN', 1);
%         Zs{jj} = pred.sameCloudFit(D, custopts);
%         nmsc{jj} = ['cloud-' num2str(ps(jj))];
%     end
%     D = pred.addAndScoreHypothesis(D, Zs, nmsc);

    Y = D.hyps(1).latents;
    NB = D.blocks(2).fImeDecoder.NulM2;
    gs = D.blocks(2).targetAngle;
    grps = sort(unique(gs));
    ngrps = numel(grps);
    
    Scs = nan(8, numel(D.hyps)-1);
    for kk = 1:ngrps
        ix = gs == grps(kk);
        
        YN = Y(ix,:)*NB;
        [u,s,v] = svd(YN);

        Zs = cell(numel(D.hyps),1);
        nms = cell(size(Zs));
        for jj = 1:numel(D.hyps)
            Yh = D.hyps(jj).latents(ix,:)*NB*v;
            Zs{jj} = Yh(:,1:2);
            nms{jj} = D.hyps(jj).name;
        end

        [P1, Ps, xs, ys, b1, bs, scs] = compareKde(Zs{1}, Zs(2:end), true);
        Scs(kk,:) = scs;

        plot.init;
        for jj = 1:numel(Zs)
            if jj == 1
                Pc = P1;
            else
                Pc = Ps{jj-1};
            end
            subplot(3,3,jj);
            plotKde(xs, ys, Pc, Zs{jj});
            title(nms{jj});
        end
    end
    
    plot.init;
    for kk = 1:size(Scs,2)
        plot(Scs(:,kk), '-o', 'LineWidth', 3);
    end
    legend(nms(2:end)); legend boxoff;
    title(D.datestr);
    
%     [~, inds] = sort({D.hyps.name});
    inds = 2:numel(D.hyps);
    figure;
    subplot(2,2,1); plot.barByHypQuick(D.score(inds), 'errOfMeans');
    subplot(2,2,2); plot.barByHypQuick(D.score(inds), 'kdeErr');
    subplot(2,2,3); plot.barByHyp(mean(Scs), nms(2:end));
%     subplot(2,1,2); plot.barByHypQuick(D.score(inds), 'covError');
%     subplot(2,2,3); plot.barByHypQuick(E.score(inds1), 'errOfMeans');
%     subplot(2,2,4); plot.barByHypQuick(E.score(inds1), 'covError');
%     title(D.datestr);
%     figure;
%     subplot(2,2,1); plot.errorByKin(D.score(inds), 'errOfMeansByKin');
%     subplot(2,2,2); plot.errorByKin(D.score(inds), 'covErrorByKin');
%     subplot(2,2,3); plot.errorByKin(E.score(inds1), 'errOfMeansByKin');
%     subplot(2,2,4); plot.errorByKin(E.score(inds1), 'covErrorByKin');
    title(D.datestr);
    
    
    
end

%%

% vs = {es11, es12, es22, es21};
% barNms = {'th', 'th, fit=thAct', 'thAct', 'thAct, fit=th'};
vs = {esBase, esIme};
barNms = {'base', 'ime'};

plot.init;
c = 0;
for jj = 2:4%numel(es11{1})
    c = c + 1;
    vals = cell(numel(vs),1);    
    subplot(1, 4, c); hold on;
    for jj = 1:numel(vs)
%         vals{jj} = cellfun(@(x) x(ii), vs{jj});
        vals{jj} = cellfun(@(x) x(jj).errOfMeans, vs{jj});
        plot(vals{jj}, '-o', 'LineWidth', 3);
    end    
%     xs = vals{xind};
%     ys = vals{yind};
%     plot(ys./xs);
%     xlabel(barNms{xind});
%     ylabel(barNms{yind});
    legend(barNms);
    legend boxoff;
    title(D.score(jj).name);
    ylim([0 2]);
end

%%

for jj = 1:5
    sc = Ss{jj};
    sc2 = Ss2{jj}
    
    S1 = {sc2(2:4).errOfMeansByKin};
    S2 = {sc(2:4).errOfMeansByKin};
    plot.init;
    for jj = [1 3]
        xs = S1{jj};
        ys = S2{jj};% - S2{2}; % deviation from pruning's scores
        plot(xs, ys, 'o');
    end
    xlabel('difference from pruning');
    ylabel('error predicting observed');
%     ylabel('error - pruning''s error');
    legend({'habitual', 'cloud'});
    title(dts{jj});
    v = axis; lo = min(v(1:2:end)); up = max(v(2:2:end)); axis([lo up lo up]);
end

%%

disp('-------');
opts = struct('nbins', nan, 'hypInds', [1 2 3 4 5], 'grpsToShow', [135], ...
    'oneKinPerFig', true, 'ttl', '', 'doFit', false, ...
    'getCounts', false, 'tightXs', true);
[~, opts] = plot.fitAndPlotMarginals(D, opts);

% set(gcf, 'PaperUnits', 'inches', 'Units', 'inches');
% pos = get(gcf, 'pos');
% set(findall(gcf,'-property','FontSize'),'FontSize', 6);
% pos = [pos(1) pos(2) 2*9 2*9];
% set(gcf,'pos', pos, 'PaperPosition', pos);
% 
% fignm = [D.datestr '-' strjoin({D.hyps(opts.hypInds).name}, '_')];
% fignm = [fignm '(nbins=' num2str(opts.nbins) ')'];
% saveas(gcf, ['plots/marginals/' fignm '.png'])

% green is cloud

%%

figure; plot.meanErrorByKinByCol(D, D.score([2 3 4 5 8 9]));

%%

% 7th dim, theta=90
% The data points that make up the histogram bars with largest discrepancies:
% - what do they look like through each mapping?
% - Where is the cursor target/location for each? 

%%

dtscur = dir('plots/moreDts');
dtscur = {dtscur(cellfun(@numel, {dtscur.name}) > 2).name};

scs = cell(numel(dtscur),1);
scsCov = scs;
for ii = 1:numel(dtscur)
    dtstr = dtscur{ii}
    X = load(['data/fits/moreDts/' dtstr '.mat']); D = X.D;
    scs{ii} = [D.score.errOfMeans];
    scsCov{ii} = [D.score.covError];
end
nms = {D.score.name};
scs = cell2mat(scs);
scsCov = cell2mat(scsCov);

%%

inds = 1:numel(nms);
inds = ~ismember(nms, {'observed', 'pruning-1', 'cloud-og'});
S = scsCov(:,inds);
dtnms = dtscur;
% [~,ix] = sort(min(S, [], 2));
% S = S(ix,:);
% dtnms = dtnms(ix);

nrm = 1;
nrm = median(S,2);
% nrm = max(S,[],2);
% nrm = scs(:,strcmp(nms, 'unconstrained'));

plot.init;
for ii = 1:size(S,2)
    plot(1:numel(dtnms), S(:,ii)./nrm, 'o-', 'LineWidth', 3);
end
set(gca, 'XTick', 1:numel(dtnms));
set(gca, 'XTickLabel', dtnms);
set(gca, 'XTickLabelRotation', 45);
ylabel('cov error');
legend(nms(inds), 'Location', 'NorthEast');
