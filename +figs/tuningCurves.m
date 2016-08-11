function tuningCurves(D, curHyps, hypClrs, baseClr)

    fig = plot.init;
    for jj = 1:numel(curHyps)
        H = pred.getHyp(D, curHyps{jj});
        curClrs = [baseClr; hypClrs(jj,:)];
        plot.blkSummaryPredicted(D, H, false, false, false, [], curClrs);
        title('');

        if jj == 1
            figxs = arrayfun(@(ii) fig.Children(ii).Position(1), 1:numel(fig.Children));
            [~,ix] = sort(figxs);
    %         ttl = @(ii) ['output-null ' num2str(ix(ii)-1)];
            ttl = @(ii) '';
            arrayfun(@(ii) title(fig.Children(ii), ttl(ii)), ...
                2:numel(fig.Children));
    %         for kk = 2:numel(fig.Children)
    %             fig.Children(kk).YLim = [-5 5];
    %         end
        end
    end
    ylabel(fig.Children(ix(2)), 'mean activity');
    set(gcf, 'Position', [0 0 1250 160]);

end

