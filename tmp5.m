
hypopts = struct('nBoots', 0, 'obeyBounds', false, ...
    'scoreGrpNm', 'targetAngle');

for jj = [5 4 3 2 1] %1:numel(dts)
    dtstr = dts{jj}
    D = fitByDate(dtstr, pms, {'habitual', 'cloud'}, popts, lopts, hypopts);

    grpNm = 'targetAngle';
%     grpNm = 'thetaGrps';
    gs1 = D.blocks(1).(grpNm);
    gs2 = D.blocks(2).(grpNm);
    Y1 = D.blocks(1).latents;
    Y2 = D.blocks(2).latents;
    RB = D.blocks(2).fImeDecoder.RowM2;
    YR1 = Y1*RB;
    YR2 = Y2*RB;

    plot.init;
    grps = sort(unique(gs1));
    clrs = cbrewer('div', 'RdYlGn', 8);
    scs = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = gs1 == grps(ii);
        mu1 = mean(YR1(ix,:));
        ix = gs2 == grps(ii);
        mu2 = mean(YR2(ix,:));

    %     plot(mu1(1), mu1(2), 'ks', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);
    %     plot(mu2(1), mu2(2), 'ko', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);

        scs(ii) = norm(mu2 - mu1);
    end
    title([D.datestr ' ' grpNm]);
    plot(grps, scs);

%     plot.init;
    plot(grps, D.score(2).errOfMeansByKin, 'r');
    plot(grps, D.score(3).errOfMeansByKin, 'Color', [0.2 0.8 0.2]);
%     title([D.datestr ' ' grpNm]);
    saveas(gcf, 'plots/tmp.png');

end
    