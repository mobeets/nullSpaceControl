
% dtstr = '20131125';
% dtstr = '20120709';
dtstr = '20120601';
% dtstr = '20120525';
% dtstr = '20120308';
D = io.quickLoadByDate(dtstr);

decNm = 'fDecoder';
% decNm = 'fImeDecoder';
[S1, S2] = tools.latentsInAllBases(D, decNm, false);

Y2 = S2.Y2;
Y1 = S2.Y1;

%%

gs = D.blocks(2).thetaGrps;
gs1 = D.blocks(1).thetaGrps;
grps = sort(unique(gs));
ncols = numel(grps);

clr1 = [200 37 6]/255;
clr2 = [22 79 134]/255;

errs = nan(numel(grps), size(Y2,2));
angErrA = nan(size(errs));
angErrB = nan(size(errs));
angErrStdA = nan(size(errs));
angErrStdB = nan(size(errs));

splitKinsByFig = false;
doCorrect = false;

if ~splitKinsByFig
    figure; set(gcf, 'color', 'w');
    nrows = size(Y2,2);
end

mns = min([Y2; Y1]);
mxs = max([Y2; Y1]);

C = 0;
c_deltas = nan(numel(grps), size(Y2,2));
deltas = nan(numel(grps),2);
for jj = 1:numel(grps)
    ix = grps(jj) == gs;
    Y2c = Y2(ix,:);
    
    ix1 = grps(jj) == gs1;
    Y1c = Y1(ix1,:);
    
    if splitKinsByFig
        figure; set(gcf, 'color', 'w');
        ncols = 4; nrows = 3;
        C = 0;
    end
    
    deltas(jj,:) = mean(Y2c(:,9:10)) - mean(Y1c(:,9:10));
    for ii = 1:size(Y2,2)
        YR2c = Y2c(:,ii);
        Zc = Y1c(:,ii);
        C = C + 1;
        
        if doCorrect && ii <= 8
            mdl = fitlm(Y1c(:,9:10), Zc);
            c_delta = 1*mdl.Coefficients.Estimate(2:end)'*deltas(jj,:)';
        else
            c_delta = 0;
        end
        c_deltas(jj,ii) = c_delta;
        Zc = Zc + c_delta;
 
        % histogram
        subplot(ncols,nrows,C); hold on;
        [c,b] = hist(YR2c, 30);
%         bar(b, c./trapz(b,c), 'FaceColor', 'w', 'EdgeColor', 'k');
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        xlabel(['YN_' num2str(ii)]);        

        % gauss estimation
        mu = mean(YR2c); sig = std(YR2c);
%         xs = linspace(min(min(Z1c), min(Yc)), max(max(Yc), max(Z1c)));
        xs = linspace(mns(ii), mxs(ii));
        ys = normpdf(xs, mu, sig);
%         plot(xs, ys, 'k-');

        % nonparam estimation        
        h = 0.1;
        Phatfcn = ksdensity_nd(YR2c, h);
        ysh = Phatfcn(xs');
        plot(xs, ysh, '-', 'Color', clr2);
                
        % show bounds                
        mn = min(YR2c); mx = max(YR2c); rng = range(YR2c);
        icdf = ksdensity_nd_icdf(Phatfcn, linspace(mn - rng/2, mx + rng/2, 1000));
        mn = icdf(0.01); mx = icdf(0.99);
        plot([mn mn], [min(ys) max(ys)], 'Color', clr2);
        plot([mx mx], [min(ys) max(ys)], 'Color', clr2);
        plot([mu mu], 0.2*[min(ys) max(ys)], 'Color', clr2);
        
        % Blk1 kde        
        h = 0.2;
        Phatfcn = ksdensity_nd(Zc, h);
        zsh = Phatfcn(xs');
        plot(xs, zsh*(max(ysh)/max(zsh)), '-', 'Color', clr1);
        
        % show Blk1 bounds
        muz = mean(Zc); sig = std(Zc);
        zs = normpdf(xs, muz, sig);
        mn = min(Zc); mx = max(Zc); rng = range(Zc);
        icdf = ksdensity_nd_icdf(Phatfcn, linspace(mn - rng/2, mx + rng/2, 1000));
        mn = icdf(0.01); mx = icdf(0.99);
        plot([mn mn], [min(ys) max(ys)], 'Color', clr1);
        plot([mx mx], [min(ys) max(ys)], 'Color', clr1);
        plot([muz muz], 0.2*[min(ys) max(ys)], 'Color', clr1);
        
        % calculate errors
        errs(jj,ii) = (muz - mu)^2;
        xlim([mns(ii) mxs(ii)]);       
        errDiff(jj,ii) = muz - mu;
        bndDiff(jj,ii) = (min(Zc) - min(YR2c)) + (max(Zc) - max(YR2c));
        
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

ds = sqrt(sum(deltas.^2,2));
plot(ds*(max(mean(errs,2))/max(ds)), 'LineWidth', 4);

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

figure;
subplot(2,2,1); hold on;
plot.quickBehavior(D, 'trial_length', 'thetaGrps', '', true);%, 'Lbest');
title('trial_length');
subplot(2,2,2); hold on;
plot.quickBehavior(D, 'isCorrect', 'thetaGrps');%, 'Lbest');
title('isCorrect');
subplot(2,2,3); hold on;
plot.quickBehavior(D, 'progress', 'thetaGrps');%, 'Lbest');
title('progress');
plot.subtitle(D.datestr);

%% row space activity

prcs = nan(numel(grps),1);

figure; set(gcf, 'color', 'w');
ncols = 3; nrows = 3;
C = 0;

YR1 = S2.YR1;
YR2 = S2.YR2;
gs1 = D.blocks(1).thetaGrps;
gs2 = D.blocks(2).thetaGrps;

for jj = 1:numel(grps)
    ix1 = grps(jj) == gs1;
    YR1c = YR1(ix1,:);
    
    ix2 = grps(jj) == gs2;
    YR2c = YR2(ix2,:);
    
    C = C + 1;
    subplot(ncols,nrows,C); hold on;
    
    plot(YR2c(:,1), YR2c(:,2), '.', 'Color', clr2, 'MarkerSize', 2);
    plot(YR1c(:,1), YR1c(:,2), '.', 'Color', clr1, 'MarkerSize', 2);    
    
    [bps,mu0,sig0] = tools.gauss2dcirc(YR2c, 2);    
    plot(mu0(1), mu0(2), 'wo', 'MarkerFaceColor', clr2, 'MarkerSize', 5);
    plot(bps(1,:), bps(2,:), '-', 'Color', clr2, 'LineWidth', 3);
    
    [bps,mu1,sig1] = tools.gauss2dcirc(YR1c, 2);
    plot(mu1(1), mu1(2), 'wo', 'MarkerFaceColor', clr1, 'MarkerSize', 5);
    plot(bps(1,:), bps(2,:), '-', 'Color', clr1, 'LineWidth', 3);
    
    plot(0, 0, 'ks', 'MarkerSize', 8);
    plot(0, 0, 'kx', 'MarkerSize', 8);
    xlim([-4 4]);
    ylim(xlim);
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    xlabel(['\theta = ' num2str(grps(jj))]);
    
    prcs(jj) = norm(mu1-mu0);
    
end

C = C + 1;
subplot(ncols, nrows, C); hold on;
xs = score.thetaCenters;
bar(1:numel(xs), prcs, 'FaceColor', 'w');
ylabel('change in mean');
set(gca, 'XTick', 1:numel(xs));
set(gca, 'XTickLabel', arrayfun(@num2str, xs, 'uni', 0));
set(gca, 'XTickLabelRotation', 45);
plot.subtitle([D.datestr ' row space']);


