
dts = {'20120525', '20120601', '20131125', '20131205'};
for ii = 1:numel(dts)
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
    
    B = D.blocks(2);
    B.datestr = D.datestr;
    B = rmfield(B, 'spikes');
    Bs2{ii} = B;
end

%%

Bsc = Bs3;
for jj = 1:numel(Bsc)
    B = Bsc{jj};
    Y = B.latents;
    NB = B.fDecoder.NulM2;
    [~,~,v] = svd(Y*NB);
    NB = NB*v;
    B.NB = NB;
    Bsc{jj} = B;
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
