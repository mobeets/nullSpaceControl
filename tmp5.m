
hypopts = struct('nBoots', 0, 'obeyBounds', false, ...
    'scoreGrpNm', 'targetAngle');

for jj = [5 4 3 2 1] %1:numel(dts)
    dtstr = dts{jj}
%     D = fitByDate(dtstr, pms, {'habitual', 'cloud'}, popts, lopts, hypopts);
    
    X = load(['data/fits/' dtstr '.mat']); D = X.D;

%     grpNm = 'targetAngle';
%     grpNm = 'thetaGrps';
    grpNm = 'thetaActualGrps16';
    
    gs1 = D.blocks(1).(grpNm);
    Y1 = D.blocks(1).latents;

%     gs1 = D.blocks(2).(grpNm);
%     Y1 = D.hyps(5).latents;
    
    gs2 = D.blocks(2).(grpNm);
    Y2 = D.blocks(2).latents;
    
    RB = D.blocks(2).fImeDecoder.RowM2;
    NB = D.blocks(2).fImeDecoder.NulM2;
    YR1 = Y1*RB;
    YR2 = Y2*RB;
    YN1 = Y1*NB;
    YN2 = Y2*NB;
    
%     [~,~,v] = svd(YN2); YN1 = YN1*v; YN2 = YN2*v; YN1 = YN1(:,1:2); YN2 = YN2(:,1:2);

    plot.init;
    grps = sort(unique(gs1));
    clrs = cbrewer('div', 'RdYlGn', 8);
    scs = nan(numel(grps),1);
    scsN = scs;
    for ii = 1:numel(grps)
        ix = gs1 == grps(ii);
        mu1 = mean(YR1(ix,:));
        muN1 = mean(YN1(ix,:));
        ix = gs2 == grps(ii);
        mu2 = mean(YR2(ix,:));
        muN2 = mean(YN2(ix,:));

%         plot(mu1(1), mu1(2), 'ks', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);
%         plot(mu2(1), mu2(2), 'ko', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);

        scs(ii) = norm(mu2 - mu1);
        scsN(ii) = norm(muN2 - muN1);
    end
    plot(scsN, scs, 'ko');
    xlabel('change in mean null space activity');
    ylabel('change in mean row space activity');
    
    vmx = max([scs; scsN]);
    xlim([0 vmx]); ylim(xlim);
    plot(xlim, ylim, 'k--');
    crr = corr(scs, scsN);
    title([D.datestr ' ' grpNm ' rsq=' num2str(crr)]);
    
%     plot(grps, scs);
%     plot(grps, D.score(3).errOfMeansByKin, 'r');
%     plot(grps, D.score(4).errOfMeansByKin, 'Color', [0.2 0.8 0.2]);
    
%     title([D.datestr ' ' grpNm]);
%     saveas(gcf, ['plots/meanChanges/' dtstr 'v2.png']);

end
    