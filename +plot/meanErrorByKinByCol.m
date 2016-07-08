function meanErrorByKinByCol(D, Hs, doStack, mx)
    if nargin < 3
        doStack = true;
    end
    if nargin < 4 || isnan(mx)
        % find max score, to scale others by
        mx = 0;
        for ii = 1:numel(Hs)
            vs = Hs(ii).errOfMeansByKinByCol;
    %         vs = Hs(ii).histErrByKinByCol;
            if isempty(vs)
                continue;
            end
            mx = max(max(vs(:)), mx);
        end
    end

    set(gcf, 'color', 'w');
    if doStack
        nrows = round(sqrt(numel(Hs)));
        ncols = ceil(numel(Hs)/nrows);
    else
        nrows = 1;
        ncols = numel(Hs);
    end
    ths = Hs(1).grps;
    for ii = 1:numel(Hs)
        subplot(nrows, ncols, ii); hold on;
        set(gca, 'FontSize', 18);
        vs = Hs(ii).errOfMeansByKinByCol';
%         vs = Hs(ii).histErrByKinByCol';
        imagesc(1:size(vs,2), 1:size(vs,1), vs);
        axis image;
        ttl = Hs(ii).name;
        if numel(Hs) == 1
            ttl = [D.datestr ': ' ttl];
        end
        title(ttl);
        caxis([0 mx]);
        colormap gray;
        axis square;
        
        if ii == 1
            if numel(ths) > 8
                lblxs = 1:2:numel(ths);
            else
                lblxs = 1:numel(ths);
            end
            lbls = arrayfun(@num2str, ths(lblxs), 'uni', 0);
            set(gca, 'XTick', lblxs);
            set(gca, 'XTickLabel', lbls');            
            set(gca, 'XTickLabelRotation', 45);
            set(gca, 'YTick', 1:size(vs,1));
            set(gca, 'YTickLabel', arrayfun(@(y) ['YN_' num2str(y)], 1:size(vs,1), 'uni', 0));
            xlabel('\theta');
        else
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
        end
        set(gca, 'YDir', 'reverse');
    end
    if numel(Hs) > 1
        plot.subtitle(D.datestr, 'FontSize', 18);
    end
    
    set(gcf, 'Position', [100 100 650 600]);
%     set(gcf, 'PaperPosition', get(gcf, 'Position'));

end
