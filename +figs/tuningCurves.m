function tuningCurves(D, curHyps, hypClrs, baseClr, opts)
    if nargin < 5
        opts = struct('doSave', false);
    end

    fig = plot.init;
    for jj = 1:numel(curHyps)
        H = pred.getHyp(D, curHyps{jj});
        curClrs = [baseClr; hypClrs(jj,:)];
        plot.blkSummaryPredicted(D, H, false, false, false, [], curClrs);
        title('');
        
        ymn = min(min(cell2mat({fig.Children.YLim}')));
        ymx = max(max(cell2mat({fig.Children.YLim}')));
%         ymn = -4; ymx = 6;

        if jj == 1
            figxs = arrayfun(@(ii) fig.Children(ii).Position(1), 1:numel(fig.Children));
            [~,ix] = sort(figxs);
    %         ttl = @(ii) ['output-null ' num2str(ix(ii)-1)];
            ttl = @(ii) '';
            arrayfun(@(ii) title(fig.Children(ii), ttl(ii)), ...
                2:numel(fig.Children));
            for kk = 2:numel(fig.Children)
                fig.Children(kk).YLim = [ymn ymx];
            end
        end
    end
    ylabel(fig.Children(ix(2)), 'mean activity');
    
    wd = 1250; ht = 160;
    set(gcf, 'Position', [0 0 wd ht]);
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [0 0 30 4]);
    if opts.doSave
        nm = ['tuning'];
        fignm = fullfile(opts.plotdir, [nm '.png']);
        saveas(fig, fignm, 'png');
    end

end

