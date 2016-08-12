function meanAndCovAllSessions(SMu, SCov, clrs, dtnms, nms)
    % order by hyps' overall mean performance across sessions
    ixs = nan(size(SMu));
    for ii = 1:size(SMu,1)
        [~,inds] = sort(SMu(ii,:));
        ixs(ii,:) = inds;
    end
    [~,indOrder] = sort(mean(ixs));
%     [~, ix] = sort(arrayfun(@(c) find(c == indOrder), curInds));

    clear figs;

    plot.init;
    figs.bar_allDts(SMu(:,indOrder), nms(indOrder), dtnms, ...
        clrs(indOrder,:), 'mean error');
    ylim([0 5]);
    set(gcf, 'Position', [0 300 1250 200]);

    plot.init;
    figs.bar_allDts(SCov(:,indOrder), nms(indOrder), dtnms, ...
        clrs(indOrder,:), 'covariance error');
    ylim([0 200]);
    set(gcf, 'Position', [0 0 1250 200]);

end
