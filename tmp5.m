baseDir = 'data/fits/allHypsAgain';

dts = io.getDatesInDir(baseDir);
grps = score.thetaCenters(16);
angs = @(yr) mod(arrayfun(@(t) tools.computeAngle(yr(t,:), [1; 0]), ...
    1:size(yr,1))', 360);
scores = nan(numel(dts),6);
objs = [];
for ii = 1:numel(dts)
    dt = dts{ii}
    indir = fullfile(baseDir, [dt '.mat']);
    if ~exist(indir, 'file')
        warning(indir);
        continue;
    end
    X = load(indir); D = X.D;
    B1 = D.blocks(1); B2 = D.blocks(2);
    Y1 = B1.latents; Y2 = B2.latents;
    NB = B2.fDecoder.NulM2;
    RB = B2.fDecoder.RowM2;
    YN1 = Y1*NB; YR1 = Y1*RB;
    YN2 = Y2*NB; YR2 = Y2*RB;
    YN2h = D.hyps(2).latents*NB;
    
    % groups
    gs1 = score.thetaGroup(angs(YR1), grps);
    gs2 = score.thetaGroup(angs(YR2), grps);
    
    % marginal histograms, histogram overlap
    histopts = struct('nbins', score.optimalBinCount(YN2, gs2, false));
    [zHist2, Xs] = tools.marginalDist(YN2, gs2, histopts);
    zHist1 = tools.marginalDist(YN1, gs1, histopts, Xs);
    zHist2h = tools.marginalDist(YN2h, gs2, histopts, Xs);
    histErr1 = score.histError(zHist2, zHist1);
    histErr2h = score.histError(zHist2, zHist2h);
    
    % error in mean/covariance
    [zMu1, ~, zNullBin1] = pred.avgByThetaGroup(YN1, gs1);
    [zMu2, ~, zNullBin2] = pred.avgByThetaGroup(YN2, gs2);
    [zMu2h, ~, zNullBin2h] = pred.avgByThetaGroup(YN2h, gs2);
    errOfMeans1 = score.errOfMeans(zMu2, zMu1);    
    covErr1 = score.covError(zNullBin2, zNullBin1);
    errOfMeans2h = score.errOfMeans(zMu2, zMu2h);
    covErr2h = score.covError(zNullBin2, zNullBin2h);
    
    clear obj;
    obj.dt = dt;
    obj.grps = grps;
    obj.gs1 = gs1;
    obj.gs2 = gs2;
%     obj.YN1 = YN1;
%     obj.YN2 = YN2;
%     obj.YN2h = YN2h;
    obj.zMu1 = zMu1;
    obj.zMu2 = zMu2;
    obj.zMu2h = zMu2h;
    obj.zNullBin1 = zNullBin1;
    obj.zNullBin2 = zNullBin2;
    obj.zNullBin2h = zNullBin2h;
    obj.zHist1 = zHist1;
    obj.zHist2 = zHist2;
    obj.zHist2h = zHist2h;
    obj.histErr1 = histErr1;
    obj.histErr2h = histErr2h;
    obj.Xs = Xs;
    objs = [objs obj];
    
    scores(ii,:) = [errOfMeans1 errOfMeans2h covErr1 covErr2h ...
        nanmean(histErr1(:)) nanmean(histErr2h(:))];
end

%%

% save('data/fits/intVsCld.mat', 'objs', 'scores');

%%

mnks = io.getMonkeys;
% mnks = {'Jeffy', 'Lincoln'};
nms = {'mean', 'cov', 'histogram overlap'};
plot.init;
c = 0;
for ii = [1 3 5]
    c = c + 1;
    subplot(3,1,c); hold on; set(gca, 'FontSize', 14);    
    for jj = 1:numel(mnks)
        ix = io.getMonkeyDateInds(dts, mnks{jj});
        plot(scores(ix,ii), scores(ix,ii+1), '.', 'MarkerSize', 15);
    end
    xl = xlim; yl = ylim;
    xmn = min([xl yl]);
    xmx = max([xl yl]);
    xlim([xmn xmx]);
    ylim(xlim);
    axis square;
    xlabel('Intuitive data');
    ylabel('Cloud prediction');
    plot(xlim, ylim, 'k--');
    title(['error in ' nms{c}]);
end

