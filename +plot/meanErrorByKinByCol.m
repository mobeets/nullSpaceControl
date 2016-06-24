function meanErrorByKinByCol(D, Hs, doStack)
    if nargin < 3
        doStack = true;
    end
    
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
    
    set(gcf, 'color', 'w');
    if doStack
        nrows = round(sqrt(numel(Hs)));
        ncols = ceil(numel(Hs)/ncols);
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
            lbls = arrayfun(@num2str, ths, 'uni', 0);
            set(gca, 'XTick', 1:numel(lbls));
            set(gca, 'XTickLabel', lbls');            
            set(gca, 'XTickLabelRotation', 45);
            set(gca, 'YTick', 1:size(vs,1));
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
