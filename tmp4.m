
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

%% choose optimal bin size

Y = D.blocks(2).latents*D.blocks(2).fDecoder.NulM2;
gs = D.blocks(2).thetaActualGrps;
gs = ones(size(gs));

trainPct = 0.9;
N = size(Y,1);

nbs = 10:5:100;
% nbs = round(linspace(20, 50, 10));
% nbs = [20 30 40 50];
% nb = round(median(max(range(Yte)) ./ (2 * iqr(Yte) / size(Yte,1)^(1/3))));
% nbs = sort([nbs nb]);

nboots = 20;
errs = nan(numel(nbs), 1, 8);
js = cell(numel(nbs),1);
for ii = 1:numel(nbs)
    es = cell(nboots,1);
    es2 = cell(nboots,1);
    for jj = 1:nboots
        
        % split training/testing
        cvobj = cvpartition(N, 'HoldOut', 1-trainPct);
        idxTrain = cvobj.training(1);
        idxTest = cvobj.test(1);
        Ytr = Y(idxTrain,:);
        Yte = Y(idxTest,:);
        gsTr = gs(idxTrain);
        gsTe = gs(idxTest);
        
        % score
        opts = struct('nbins', nbs(ii));
        [Z, Xs, grps] = tools.marginalDist(Ytr, gsTr, opts);
        [Zh, ~, ~] = tools.marginalDist(Yte, gsTe, opts, Xs);
        
%         [Zh, Xs, ~] = tools.marginalDist(Yte, gsTe, opts);
%         for kk = 1:size(Zh{1},2)
%             Xsamp = histSample(Xs{1}(:,kk), Zh{1}(:,kk), nsamps);
%         end        
        
        es{jj} = score.histError(Z, Zh);
    end
    errs(ii,:,:) = mean(cat(3, es{:}),3);
    js{ii} = es;
end

%%

plot.init;
for ii = 1:8
    errc = cell2mat(cellfun(@(y) cellfun(@(x) x(1,ii), y), js, 'uni', 0)');
    plot(nbs, 1e6*mean(errc,1)./nbs, '-o');
end

%%
plot.init;
for jj = 1:8
%     subplot(2,4,jj); hold on;
    err = mean(squeeze(errs(:,2,jj)),2);
    plot(nbs, err./nbs', 'o-', 'LineWidth', 3);
    xlabel('nbins');
    ylabel('hist error');
end

%%

Y = D.blocks(2).latents*D.blocks(2).fDecoder.NulM2;
gs = D.blocks(2).thetaActualGrps;
% gs = ones(size(Y,1),1);
% [Zs, Xs] = tools.marginalDist(Y, gs);

plot.init;
grps = sort(unique(gs));
yc = cell(numel(grps),1);
for ii = 1:numel(grps)
    ix = grps(ii) == gs;
    Yc = Y(ix,:);
    n = size(Yc,1);
    rng = range(Yc);
    rng = max(max(Yc)) - min(min(Yc));

    crit = @(cs, h) 2./((n-1).*h) - sum(cs.^2)*(n+1)./((n-1)*n^2.*h);
%     crit = @(cs, h) (2*mean(cs) - var(cs, 1))/h^2;
    
    cfcn = @(h) tools.marginalDist(Yc, ones(n,1), struct('nbins', h, ...
        'getCounts', true));
    getcellind = @(fcn, ind) fcn{ind};
    obj = @(h) crit(getcellind(cfcn(h), 1), rng/h);
    
    xs = 10:200;
    ys = cell2mat(arrayfun(obj, xs, 'uni', 0)');
    yc{ii} = mean(zscore(ys),2);
    plot(xs, yc{ii}, '-', 'LineWidth', 2);
%     for jj = 1:size(ys,2)
%         plot(xs, zscore(ys(:,jj)), '-');
%     end
    
end
ya = mean(cell2mat(yc'),2);
plot(xs, ya, 'k-', 'LineWidth', 3);

