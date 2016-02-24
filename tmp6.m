
dts = {'20120525', '20120601', '20131125', '20131205'};
for ii = 1:1%1:numel(dts)
    dtstr = dts{ii};
    D = io.loadRawDataByDate(dtstr);
    D.params = io.setParams(D);
    D.params.START_SHUFFLE = nan;
    D.trials = io.makeTrials(D);
    D.params = io.setFilterDefaults(D.params);
    D.trials.thetaGrps = score.thetaGroup(D.trials.thetas + 180, ...
        score.thetaCenters(8));
    D.params.MAX_ANGULAR_ERROR = 360;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    D = tools.rotateLatentsUpdateDecoders(D, true);
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);

    plot.cursorMovementByBlock(D);
%     B = D.blocks(1);
%     B.datestr = D.datestr;
%     B = rmfield(B, 'spikes');
%     Bs1{ii} = B;
end

%%

Bsc = Bs1;
for jj = 1:numel(Bsc)
    B = Bsc{jj};
    Y = B.latents;
    NB = B.fDecoder.NulM2;
    RB = B.fDecoder.RowM2;
    [~,~,v] = svd(Y*NB);
    B.NB0 = NB;
    NB = NB*v;
    B.NB = NB;    
    B.RB = RB;
    
    Bsc{jj} = B;
end

%%

Bsc = Bs1;
% figure; set(gcf, 'color', 'w');
for jj = 1:numel(Bsc)
    B = Bsc{jj};
    B2 = Bs2{jj};
    
    Y = B.latents;
    
    xs = B.trial_index;
    xsb = [1 prctile(xs, [25 50 75]) size(xs,1)];
    xsbl = [25 50 75 100];
    ysr = Y*B2.RB;
    ysn = Y*B2.NB;
    
    gs = B.thetaGrps;
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    
    figure; set(gcf, 'color', 'w');    
    hold on; box off; set(gca, 'FontSize', 14);
    
    vs1 = nan(numel(grps), numel(xsb)-1);
    vs2 = nan(size(vs1));
    vs3 = nan(size(vs1));
    vs4 = nan(size(vs1));
    for ii = 1:numel(grps)
        subplot(2,4,ii); hold on;
        ixg = gs == grps(ii);
        for kk = 1:numel(xsb)-1
            ixt = xs >= xsb(kk) & xs <= xsb(kk+1);
            ix = ixt & ixg;
            vs1(ii,kk) = corr(ysr(ix,1), ysn(ix,1));
            vs2(ii,kk) = corr(ysr(ix,1), ysn(ix,2));
            vs3(ii,kk) = corr(ysr(ix,2), ysn(ix,1));
            vs4(ii,kk) = corr(ysr(ix,2), ysn(ix,2));
        end
%         plot(xsbl, vs1(ii,:), '-', 'Color', clrs(ii,:), 'LineWidth', 3);
%         plot(xsbl, vs1(ii,:), 'o', 'MarkerFaceColor', clrs(ii,:), 'Color', clrs(ii,:));
        
        vsc = vs1;
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], '-', 'Color', clrs(ii,:), 'LineWidth', 3);
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], '+', 'MarkerFaceColor', clrs(ii,:), 'Color', clrs(ii,:));
        vsc = vs2;
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], '-', 'Color', clrs(ii,:), 'LineWidth', 3);
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], 'x', 'MarkerFaceColor', clrs(ii,:), 'Color', clrs(ii,:));
        vsc = vs3;
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], '-', 'Color', clrs(ii,:), 'LineWidth', 3);
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], '*', 'MarkerFaceColor', clrs(ii,:), 'Color', clrs(ii,:));
        vsc = vs4;
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], '-', 'Color', clrs(ii,:), 'LineWidth', 3);
        plot([xsbl(1) xsbl(end)], [vsc(ii,1) vsc(ii,end)], 'o', 'MarkerFaceColor', clrs(ii,:), 'Color', clrs(ii,:));
        plot(xsbl, zeros(numel(xsb)-1), 'k--');
        ylim([-1 1]);
        set(gca, 'YTick', -1:0.5:1);
    end    
%     plot(grps, vs1, '-', 'Color', [0.8 0.2 0.2], 'LineWidth', 3);
%     plot(grps, vs2, '-', 'Color', [0.8 0.6 0.6], 'LineWidth', 3);
%     plot(grps, vs3, '-', 'Color', [0.2 0.2 0.8], 'LineWidth', 3);
%     plot(grps, vs4, '-', 'Color', [0.6 0.6 0.8], 'LineWidth', 3);
%     plot(grps, zeros(size(grps)), 'k--');
%     legend({'R1-N1', 'R1-N2', 'R2-N1', 'R2-N2'}, 'Location', 'BestOutside');
%     set(gca, 'XTick', grps);
%     set(gca, 'XTickLabelRotation', 45);
    plot(xsbl, zeros(numel(xsb)-1), 'k--');
    ylim([-1 1]);
    set(gca, 'YTick', -1:0.5:1);
    title(B.datestr);
%     xlabel('\theta');
    xlabel('percentile');
    ylabel('corr(YR, YN)');
end



%%
for jj = 1:numel(Bs2)
    B = Bs2{jj};
    B1 = Bs1{jj};
    
    Y = B.latents;
%     NB = B.fDecoder.NulM2;
%     [~,~,v] = svd(Y*NB);
%     NB = NB*v;
    NB = B.NB;
    ys = Y*NB;
    xs = B.trial_index;
    xsb = prctile(xs, [25, 85]);
    
    xs1 = B1.trial_index;
    xsb1 = prctile(xs1, 50);
    NB1 = B1.NB;
    ys1 = B1.latents*NB1;
    gs1 = B1.thetaGrps;

    gs = B.thetaGrps;
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));

    smth = 100;
    figure; set(gcf, 'color', 'w');
    hold on; box off; set(gca, 'FontSize', 14);
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        ix1 = gs1 == grps(ii);
        
        xscs = [];
        yscs = [];
        
%         xsc = xs1(ix1,:);
%         ysc = ys1(ix1,:);
%         ixc = xsc > xsb1;
%         xscs = [xscs 0];
%         yscs = [yscs; nanmean(ysc(ixc,:))];
%         xsc = xs(ix);
%         ysc = ys(ix,:);
%         x0 = xsb(1);
%         ixc = xsc < x0;
%         xscs = [xscs x0];
%         yscs = [yscs; nanmean(ysc(ixc,:))];
%         
%         plot3(xscs, yscs(:,1), yscs(:,2), ...
%             '-', 'color', clrs(ii,:), 'LineWidth', 3);
%         plot3(xscs(1), yscs(1,1), yscs(1,2), ...
%             'o', 'color', 'k', ...
%             'LineWidth', 3, 'HandleVisibility', 'off');
%         plot3(xscs(2), yscs(2,1), yscs(2,2), ...
%             'o', 'color', clrs(ii,:), ...
%             'LineWidth', 3, 'HandleVisibility', 'off');
%         continue;
        
        
%         xsc = xs1(ix1,:);
%         ysc = ys1(ix1,:);
%         ixc = xsc < xsb1;
%         xscs = [xscs 0 xsb1];
%         yscs = [yscs; nanmean(ysc(ixc,:)); nanmean(ysc(~ixc,:))];        
%         
%         plot3(xscs, yscs(:,1), yscs(:,2), ...
%             '-', 'color', clrs(ii,:), 'LineWidth', 3);
%         plot3(xscs(1), yscs(1,1), yscs(1,2), ...
%             'o', 'color', 'k', ...
%             'LineWidth', 3, 'HandleVisibility', 'off');
%         plot3(xscs(2), yscs(2,1), yscs(2,2), ...
%             'o', 'color', clrs(ii,:), ...
%             'LineWidth', 3, 'HandleVisibility', 'off');
%         continue;
        
        ys1 = B1.latents(ix1,:)*NB;
        ninds = size(ys1,1);
        ysc0 = nanmean(ys1(max(ninds-300,1):end,:));
        xscs = [xscs min(xs)];
        yscs = [yscs ysc0];
        
        xsc = xs(ix);
        ysc = ys(ix,:);        
        
        x0 = xsb(1);
        ixc = xsc < x0;
        xscs = [xscs x0];
        yscs = [yscs; nanmean(ysc(ixc,:))];
        
        x0 = xsb;
        ixc = xsc >= xsb(1) & xsc <= xsb(2);
        xscs = [xscs mean(x0)];
        yscs = [yscs; nanmean(ysc(ixc,:))];
        
        x0 = xsb(2);
        ixc = xsc > x0;
        xscs = [xscs x0];
        yscs = [yscs; nanmean(ysc(ixc,:))];
        
        plot3(xscs, yscs(:,1), yscs(:,2), ...
            '-', 'color', clrs(ii,:), 'LineWidth', 3);
        plot3(xscs(1), yscs(1,1), yscs(1,2), ...
            'o', 'color', 'k', ...
            'LineWidth', 3, 'HandleVisibility', 'off');
        plot3(xscs(end), yscs(end,1), yscs(end,2), ...
            'ko', 'color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:), ...
            'LineWidth', 3, 'HandleVisibility', 'off');
        
%         plot3(xs(ix), smooth(xs(ix), ys(ix,1), smth), ...
%             smooth(xs(ix), ys(ix,2), smth), ...
%             '-', 'color', clrs(ii,:), 'LineWidth', 3);
    end
    xlabel('trial index');
    ylabel('Null activity along 1st PC');
    zlabel('Null activity along 2nd PC');
    title(B.datestr);
    plot3(median(xs), 0, 0, '+k');
    legend(arrayfun(@(ii) num2str(grps(ii)), 1:numel(grps), 'uni', 0), ...
        'Location', 'BestOutside');
    
    xmn = 6;
    ylim([-xmn xmn]);
    zlim(ylim);
    
end
