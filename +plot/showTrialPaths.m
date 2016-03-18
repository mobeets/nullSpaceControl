function showTrialPaths(B, ix)
    if nargin < 2
        ix = true(size(B.pos,1),1);
    end    
    
    set(gcf, 'color', 'w');
    
    ts = B.trial_index;
    trs = sort(unique(ts(ix)));
    bins = [0 20 40 60 80 100];
    trBins = prctile(trs, bins);
    clrs = gray(numel(trBins)+1);
    for jj = 1:numel(trBins)-1
        subplot(3,2,jj);
%         clf;
%         set(gcf, 'color', 'w');
        hold on;
        set(gca, 'FontSize', 14);        
        ij = (ts >= trBins(jj)) & (ts < trBins(jj+1));
        for ii = 1:numel(trs)
            tix = (trs(ii) == ts) & ix & ij;
            ps = B.pos(tix,:);
            v = plot(ps(:,1), ps(:,2), '-', 'Color', clrs(jj,:));
%             v.Color = [v.Color 0.2];
        end
        drawStartAndTargs(B, ix);
        xlabel([num2str(bins(jj+1)) 'th percentile']);
    end
        
%     clrs = copper(numel(trBins)+1);
%     for ii = 1:numel(trBins)-1
%         tix = (ts >= trBins(ii)) & (ts < trBins(ii+1)) & ix;
%         ps = B.pos(tix,:);
%         tm = B.time(tix,:);
%         tms = sort(unique(tm));
%         vs = nan(numel(tms),2);
%         for jj = 1:numel(tms)
%             vs(jj,:) = median(ps(tms(jj) == tm,:));
%         end
%         v = plot(vs(:,1), vs(:,2), '-', 'Color', clrs(ii+1,:), 'LineWidth', 2);
%     end
    
%     drawStartAndTargs(B, ix);
    
end

function drawStartAndTargs(B, ix)    
    
    % set bounds
    st = median(B.target);
    xl = tools.getLims([B.target(:,1); st(1)], 0.2);
    yl = tools.getLims([B.target(:,2); st(2)], 0.2);
    xlim(xl);
    ylim(yl);
    
    % draw start
    plot(st(1), st(2), 'r+', 'MarkerSize', 10, ...
            'MarkerFaceColor', [0.8 0.2 0.2]);
    
    % draw targets
    trgs = score.thetaCenters(8);    
    clrs = cbrewer('div', 'RdYlGn', numel(trgs));
    ctrg = [B.target(ix,:) B.targetAngle(ix, :)];
    ctrgs = unique(ctrg(~any(isnan(ctrg),2),:), 'rows');
    for ii = 1:size(ctrgs,1)
        plot(ctrgs(ii,1), ctrgs(ii,2), 'ko', 'MarkerSize', 8, ...
            'MarkerFaceColor', clrs(ctrgs(ii,3) == trgs,:));
    end
end
