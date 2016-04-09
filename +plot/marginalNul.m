
D = io.quickLoadByDate('20120525');
B = D.blocks(2);
Y = B.latents;
NB = B.fDecoder.NulM2;
RB = B.fDecoder.RowM2;
% NB = B.fImeDecoder.NulM2;
% [u,s,v] = svd(Y*NB); NB = NB*v;
YN = Y*NB;
YR = Y*RB;

ZN1 = D.blocks(1).latents*NB;
gs1 = D.blocks(1).thetaGrps;

RB1 = D.blocks(1).fDecoder.RowM2;
YR1 = D.blocks(1).latents*RB1;
ZR1 = D.blocks(1).latents*RB;

%%

figure; set(gcf, 'color', 'w');
ncols = size(YN,2);

gs = B.thetaGrps;
grps = sort(unique(gs));
nrows = numel(grps);

errs = nan(numel(grps), size(YN,2));

C = 0;
for jj = 1:numel(grps)
    ix = grps(jj) == gs;
    YNc = YN(ix,:);
    
    ix1 = grps(jj) == gs1;
    ZN1c = ZN1(ix1,:);
    
    figure; set(gcf, 'color', 'w');
    ncols = 3; nrows = 3;
    C = 0;
    
    for ii = 1:size(YN,2)
        Yc = YNc(:,ii);
        Z1c = ZN1c(:,ii);
        C = C + 1;
 
%         subplot(ncols,nrows,2*ii-1); hold on;
        subplot(ncols,nrows,C); hold on;
        [c,b] = hist(Yc, 30);
%         bar(b, c./trapz(b,c), 'FaceColor', 'w', 'EdgeColor', 'k');
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        xlabel(['YN_' num2str(ii)]);        

        % gauss estimation
        mu = mean(Yc); sig = std(Yc);
        xs = linspace(min(Yc), max(Yc));
        ys = normpdf(xs, mu, sig);
%         plot(xs, ys, 'k-');
        
        mn = min(Yc); mx = max(Yc);
        plot([mn mn], [min(ys) max(ys)], 'k');
        plot([mx mx], [min(ys) max(ys)], 'k');        

        % nonparam estimation
        h = 0.1;
        Phatfcn = ksdensity_nd(Yc, h);
        ysh = Phatfcn(xs');
        plot(xs, ysh, '-', 'Color', [0.8 0.2 0.2]);
        
        % Blk1 gauss
        clr1 = [0.2 0.2 0.8];
        h = 0.1;
        Phatfcn = ksdensity_nd(Z1c, h);
        zsh = Phatfcn(xs');
        plot(xs, zsh, '-', 'Color', clr1);
        
        muz = mean(Z1c); sig = std(Z1c);
        zs = normpdf(xs, muz, sig);
%         plot(xs, zs, '-', 'Color', clr1);
        mn = min(Z1c); mx = max(Z1c);
        plot([mn mn], [min(ys) max(ys)], 'Color', clr1);
        plot([mx mx], [min(ys) max(ys)], 'Color', clr1);
        
%         errs(jj,ii) = sqrt(sum((ysh - zs).^2));
        errs(jj,ii) = (muz - mu)^2;
    
        if ii == 1
            ylabel(['\theta = ' num2str(grps(jj))]);
        end

    end
end
plot.subtitle(D.datestr);

%%

figure; plot(mean(errs,2));
figure; imagesc(errs);
caxis([0 round(max(errs(:)))]);
colormap gray;

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
