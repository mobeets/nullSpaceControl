function meanErrorByKinByCol(D, Hs)
    
    % find max score, to scale others by
    mx = 0;
    for ii = 1:numel(Hs)
        vs = Hs(ii).errOfMeansByKinByCol;
        mx = max(max(vs(:)), mx);
    end
    
    set(gcf, 'color', 'w');
    ncols = round(sqrt(numel(Hs)));
    nrows = ceil(numel(Hs)/ncols);
    for ii = 1:numel(Hs)
        subplot(ncols, nrows, ii); hold on;
        set(gca, 'FontSize', 18);
        
        imagesc(Hs(ii).errOfMeansByKinByCol);
        axis image;
        title(Hs(ii).name);
        caxis([0 mx]);
        colormap gray;
        axis square;
        
        if ii == 1
            lbls = arrayfun(@num2str, score.thetaCenters, 'uni', 0);
            set(gca, 'YTick', score.thetaCenters);
            set(gca, 'YTickLabel', lbls');
            set(gca, 'XTick', 1:size(vs,2));
            ylabel('\theta');
        else
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
        end
        set(gca, 'YDir', 'reverse');
    end
    plot.subtitle(D.datestr);

end
