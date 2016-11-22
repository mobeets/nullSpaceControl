function bar_oneDt(S, nms, clrs, ylbl, bs, ymx, pts)
    if nargin < 5
        bs = [];
    end
    if nargin < 6
        ymx = nan;
    end

    for ii = 1:numel(nms)        
        bar(ii, S(ii), 'FaceColor', clrs(ii,:), 'EdgeColor', clrs(ii,:));
%         bar(ii, S(ii), 'FaceColor', 'w', 'EdgeColor', 'k');
%         plot([ii-0.5 ii+0.5], [S(ii) S(ii)]);        
%         jtr = rand(size(pts,1),1)/2-0.25;
%         jtr = 1:size(pts,1); jtr = (jtr - mean(jtr))/var(jtr);
%         plot(ii*ones(size(pts,1),1) + jtr', pts(:,ii), 'o', 'MarkerFaceColor', clrs(ii,:), 'MarkerEdgeColor', 'k');
        
        if isempty(pts)
            continue;
        end
        cpts = pts(:,ii);
        cptsu = unique(cpts);
        cmx = 1*size(pts,1);
        for jj = 1:numel(cptsu)
            ix = cpts == cptsu(jj);
            jtr = 1:sum(ix); jtr = (jtr - mean(jtr))/cmx;
            plot(ii*ones(sum(ix),1) + jtr', cpts(ix), 'o', ...
                'MarkerSize', 5, ...
                'MarkerFaceColor', clrs(ii,:), ...
                'MarkerEdgeColor', 'k');
        end
    end
    if ~isempty(bs)
        for ii = 1:numel(nms)
            plot([ii ii], bs(:,ii), 'k-');
        end
    end

    set(gca, 'XTick', 1:numel(nms));
    set(gca, 'XTickLabel', nms);
    set(gca, 'TickDir', 'out');
    set(gca, 'Ticklength', [0 0]);
    if max(cellfun(@numel, nms)) > 3 % if longest name > 3 chars
        set(gca, 'XTickLabelRotation', 45);
    end
    xlim([0.25 numel(nms)+0.75]);
    ylabel(ylbl);
    if ~isnan(ymx)
        ylim([0 ymx]);
        set(gca, 'YTick', 1:ymx);
%         ylbls = arrayfun(@num2str, 1:ymx, 'uni', 0);
%         ylbls{1} = '(best) 1';
%         ylbls{end} = ['(worst) ' ylbls{end}];
%         set(gca, 'YTickLabel', ylbls);
    end

end
