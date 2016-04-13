
% dtstr = '20131125';
% dtstr = '20120709';
% dtstr = '20120601';
dtstr = '20120525';
D = io.quickLoadByDate(dtstr);
B = D.blocks(2);
Y = B.latents;
% NB = B.fDecoder.NulM2;
% RB = B.fDecoder.RowM2;

NB = B.fImeDecoder.NulM2;
RB = B.fImeDecoder.RowM2;

% [u,s,v] = svd(Y*NB); NB = NB*v;
YN = Y*NB;
YR = Y*RB;

ZN1 = D.blocks(1).latents*NB;
gs1 = D.blocks(1).thetaGrps;

% NB1 = D.blocks(1).fDecoder.NulM2;
% RB1 = D.blocks(1).fDecoder.RowM2;
NB1 = D.blocks(1).fImeDecoder.NulM2;
RB1 = D.blocks(1).fImeDecoder.RowM2;
YR1 = D.blocks(1).latents*RB1;
ZR1 = D.blocks(1).latents*RB;

ZNR = D.blocks(1).latents*(RB1*RB1')*NB;
ZNN = D.blocks(1).latents*(NB1*NB1')*NB;
ZN1 = ZNN;

%%

YN = [YN YR];
ZN1 = [ZN1 D.blocks(1).latents*RB];

%%

gs = B.thetaGrps;
grps = sort(unique(gs));
ncols = numel(grps);

errs = nan(numel(grps), size(YN,2));
angErrA = nan(size(errs));
angErrB = nan(size(errs));
angErrStdA = nan(size(errs));
angErrStdB = nan(size(errs));

splitKinsByFig = true;

if ~splitKinsByFig
    figure; set(gcf, 'color', 'w');
    nrows = size(YN,2);
end

mns = min([YN; ZN1]);
mxs = max([YN; ZN1]);

C = 0;
c_deltas = nan(numel(grps), size(YN,2));
for jj = 1:numel(grps)
    ix = grps(jj) == gs;
    YNc = YN(ix,:);
    
    ix1 = grps(jj) == gs1;
    ZN1c = ZN1(ix1,:);
    
    if splitKinsByFig
        figure; set(gcf, 'color', 'w');
        ncols = 4; nrows = 3;
        C = 0;
    end
    
    delta = mean(YNc(:,9:10)) - mean(ZN1c(:,9:10));
    for ii = 1:size(YN,2)
        Yc = YNc(:,ii);
        Z1c = ZN1c(:,ii);
        C = C + 1;
        
        if ii <= 8
            mdl = fitlm(ZN1c(:,9:10), Z1c);
            c_delta = 1.7*mdl.Coefficients.Estimate(2:end)'*delta';
        else
            c_delta = 0;
        end
        c_deltas(jj,ii) = c_delta;
        Z1c = Z1c + c_delta;
 
        % histogram
        subplot(ncols,nrows,C); hold on;
        [c,b] = hist(Yc, 30);
%         bar(b, c./trapz(b,c), 'FaceColor', 'w', 'EdgeColor', 'k');
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        xlabel(['YN_' num2str(ii)]);        

        % gauss estimation
        mu = mean(Yc); sig = std(Yc);
%         xs = linspace(min(min(Z1c), min(Yc)), max(max(Yc), max(Z1c)));
        xs = linspace(mns(ii), mxs(ii));
        ys = normpdf(xs, mu, sig);
%         plot(xs, ys, 'k-');
        
        % show bounds
        clr2 = [22 79 134]/255;        
        mn = min(Yc); mx = max(Yc);
        plot([mn mn], [min(ys) max(ys)], 'Color', clr2);
        plot([mx mx], [min(ys) max(ys)], 'Color', clr2);
        plot([mu mu], 0.2*[min(ys) max(ys)], 'Color', clr2);

        % nonparam estimation
        h = 0.1;
        Phatfcn = ksdensity_nd(Yc, h);
        ysh = Phatfcn(xs');
        plot(xs, ysh, '-', 'Color', clr2);
        
        % Blk1 kde
        clr1 = [200 37 6]/255;
        h = 0.2;
        Phatfcn = ksdensity_nd(Z1c, h);
        zsh = Phatfcn(xs');
        plot(xs, zsh*(max(ysh)/max(zsh)), '-', 'Color', clr1);
        
        % show Blk1 bounds
        muz = mean(Z1c); sig = std(Z1c);
        zs = normpdf(xs, muz, sig);
        mn = min(Z1c); mx = max(Z1c);
        plot([mn mn], [min(ys) max(ys)], 'Color', clr1);
        plot([mx mx], [min(ys) max(ys)], 'Color', clr1);
        plot([muz muz], 0.2*[min(ys) max(ys)], 'Color', clr1);
        
        % calculate errors
        errs(jj,ii) = (muz - mu)^2;
        xlim([mns(ii) mxs(ii)]);       
        errDiff(jj,ii) = muz - mu;
        bndDiff(jj,ii) = (min(Z1c) - min(Yc)) + (max(Z1c) - max(Yc));
        
        % Blk1 kde: unshifted verson
%         clr3 = [37 200 6]/255;
%         h = 0.2;
%         Phatfcn = ksdensity_nd(Z1c - c_delta, h);
%         zsh = Phatfcn(xs');
%         plot(xs, zsh*(max(ysh)/max(zsh)), '--', 'Color', clr3);
    
        if ii == 1
            ylabel(['\theta = ' num2str(grps(jj))]);
        end

    end
end
plot.subtitle(D.datestr);

%%

xs = score.thetaCenters;
figure; set(gcf, 'color', 'w');
subplot(2,1,1); hold on; set(gca, 'FontSize', 18);
plot(mean(errs,2), 'LineWidth', 4);
set(gca, 'XTick', 1:numel(xs));
set(gca, 'XTickLabel', arrayfun(@num2str, xs, 'uni', 0));
set(gca, 'XTickLabelRotation', 45);
ylabel('avg error in mean');

subplot(2,1,2); hold on; set(gca, 'FontSize', 18);
imagesc(1:size(errs,2), 1:size(errs,1), errs);
caxis([0 round(max(errs(:)))]);
colormap gray;
axis image;
set(gca, 'YDir', 'reverse');
set(gca, 'XTick', 1:size(errs,2));
set(gca, 'YTick', 1:numel(xs));
set(gca, 'YTickLabel', arrayfun(@num2str, xs, 'uni', 0));
set(gca, 'YTickLabelRotation', 45);
title('error in mean');

plot.subtitle(D.datestr);

%%

errs = nan(numel(grps));
for jj = 1:numel(grps)
    ix = grps(jj) == gs;
    YNc = YN(ix,:);
    
    ix1 = grps(jj) == gs1;
    ZN1c = ZN1(ix1,:);
    
    delta = mean(YNc(:,9:10)) - mean(ZN1c(:,9:10));
    for kk = 1:8
        mdl = fitlm(ZN1c(:,9:10), ZN1c(:,kk));
        ZN1c2 = mdl.predict(ZN1c(:,9:10) + delta);
    end
end
figure; imagesc(errs);
caxis([0 max(errs(:))]);

%%

cr = cell(numel(grps),1);
for jj = 1:numel(grps)
    ix = grps(jj) == gs;
    YNc = YN(ix,:);
    cr{jj} = abs(corr(YNc));
end
cr = cat(3, cr{:});

figure; set(gcf, 'color', 'w');
for jj = 1:8
    subplot(3,3,jj); hold on;    
    cc = squeeze(cr(jj,10,:));
    bar(score.thetaCenters, cc);
    set(gca, 'XTick', score.thetaCenters);
    set(gca, 'XTickLabel', arrayfun(@num2str, score.thetaCenters, 'uni', 0));
    set(gca, 'XTickLabelRotation', 45);
    ylim([0 1]);
    title(['col ' num2str(jj)]);
end
    
%%

figure; set(gcf, 'color', 'w');
hold on; box off; set(gca, 'FontSize', 24);
clrs = cbrewer('div', 'RdYlGn', 8);
xxs = linspace(prctile(bndDiff(:), 10), prctile(bndDiff(:), 90));
for jj = 1:size(bndDiff,1)
    xx = bndDiff(jj,:);
    yy = errDiff(jj,:);
    mdl = fitlm(xx,yy, 'Intercept', false);
    plot(xxs, mdl.predict(xxs'), '-', 'LineWidth', 3, 'Color', clrs(jj,:));
    ws(jj) = mdl.Coefficients.Estimate;
    plot(xx, yy, '.', 'Color', clrs(jj,:), 'MarkerSize', 20);
end
box off;
set(gca, 'XTick', [0]);
set(gca, 'YTick', [0]);
xlabel('change in upper/lower bounds');
ylabel('change in mean');


%%

optsR = struct('doNull', false, 'doRow', true, 'blockInd', 1, ...
    'mapInd', 2, 'grpName', 'thetaGrps');
angDst = @(a1,a2) abs(mod((a1-a2 + 180), 360) - 180);
angDstBlk = @(A1,A2) arrayfun(@(ii) angDst(A1(ii), A2(ii)), 1:size(A1,1));

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    D = io.quickLoadByDate(dts{ii});
    thFcn = @(Y) arrayfun(@(ii) mod(tools.computeAngle(Y(ii,:)', [0; 1]), ...
        360), 1:size(Y,1));
%     thFcn = @(Y) mod(tools.computeAngle(mean(Y), [0; 1]), 360);
%     grpFcn = @(Y) score.thetaGroup(thFcn(Y), score.thetaCenters);
%     [vs, grps] = tools.valsByGrp(D, grpFcn, optsR);
    
    [vs, grps] = tools.valsByGrp(D, thFcn, optsR);
    cnts = score.thetaCenters;
    prcs = arrayfun(@(ii) mean(vs{ii} == cnts(ii)), 1:numel(cnts));
    
    B = D.blocks(1);
    for jj = 1:numel(grps)
        ix = grps(jj) == B.thetaGrps;
%         prcs(jj) = angDst(mean(B.thetas(ix)), mean(vs{jj}'));
        prcs(jj) = median(angDstBlk(B.thetas(ix), vs{jj}'));
%         prcs(jj) = mean((B.thetas(ix)' - vs{jj}).^2);
    end
%     prcs = prcs./max(prcs);
    
    subplot(2,3,ii); hold on;
    plot.singleValByGrp([],[],[], prcs, grps);
    
    if ii == 1
        ylabel('median \theta_1 - \theta_2');
    else
        ylabel('');
    end
    ylim([0 180]);
%     ylabel('pct still in thetaGrp');
%     ylim([0 0.4]);
    title(D.datestr);
end


%%

clr0 = [0.2 0.8 0.2];
clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];
prcs = nan(numel(grps),1);

figure; set(gcf, 'color', 'w');
C = 0;

for jj = 1:numel(grps)
    ix1 = grps(jj) == gs1;
    YRc = YR1(ix1,:);
    ZR1c = ZR1(ix1,:);
    
    ix = grps(jj) == gs;
    Yc = YR(ix,:);
    
    C = C + 1;
    subplot(ncols,nrows, C); hold on;
    
    [bps,mu0,sig0] = tools.gauss2dcirc(Yc, 2);
    plot(mu0(1), mu0(2), '.', 'Color', clr0, 'MarkerSize', 20);
    plot(bps(1,:), bps(2,:), '-', 'Color', clr0);
    
    [bps,mu1,sig1] = tools.gauss2dcirc(YRc, 2);
    plot(mu1(1), mu1(2), '.', 'Color', clr2, 'MarkerSize', 20);
    plot(bps(1,:), bps(2,:), '-', 'Color', clr2);
    [bps,mu2,sig2] = tools.gauss2dcirc(ZR1c, 2);
    plot(mu2(1), mu2(2), '.', 'Color', clr1, 'MarkerSize', 20);
    plot(bps(1,:), bps(2,:), '-', 'Color', clr1);
    plot(0, 0, 'ks', 'MarkerSize', 8);
    plot(0, 0, 'kx', 'MarkerSize', 8);
    
    prcs(jj) = norm(mu2-mu0);
    
    xlim([-4 4]);
    ylim(xlim);
end
