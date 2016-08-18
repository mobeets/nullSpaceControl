function meanAndCovAllSessions(SMu, SCov, clrs, dtnms, nms, setLims)
    if nargin < 6
        setLims = [5 200];
    end
    % order by hyps' overall mean performance across sessions
    ixs = nan(size(SMu));
    for ii = 1:size(SMu,1)
        [~,inds] = sort(SMu(ii,:));
        [~,inds] = sort(inds);
        ixs(ii,:) = inds;
    end
    [~,indOrder] = sort(mean(ixs));
%     [~, ix] = sort(arrayfun(@(c) find(c == indOrder), curInds));

    clear figs;

    plot.init;
    figs.bar_allDts(SMu(:,indOrder), nms(indOrder), dtnms, ...
        clrs(indOrder,:), 'mean error');
    if ~isnan(setLims(1))
        ylim([0 setLims(1)]);
    end
    set(gcf, 'Position', [0 300 1250 200]);

    plot.init;
    figs.bar_allDts(SCov(:,indOrder), nms(indOrder), dtnms, ...
        clrs(indOrder,:), 'covariance error');
    if ~isnan(setLims(2))
        ylim([0 setLims(2)]);
    end
    set(gcf, 'Position', [0 0 1250 200]);

end
