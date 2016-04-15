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
    ths = score.thetaCenters;
    for ii = 1:numel(Hs)
        subplot(ncols, nrows, ii); hold on;
        set(gca, 'FontSize', 18);
        vs = Hs(ii).errOfMeansByKinByCol';
        imagesc(1:numel(ths), 1:size(vs,2), vs);
        axis image;
        title(Hs(ii).name);
        caxis([0 mx]);
        colormap gray;
        axis square;
        
        if ii == 1
            lbls = arrayfun(@num2str, ths, 'uni', 0);
            set(gca, 'XTick', 1:numel(lbls));
            set(gca, 'XTickLabel', lbls');            
            set(gca, 'XTickLabelRotation', 45);
            set(gca, 'YTick', 1:size(vs,2));
            xlabel('\theta');
        else
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
        end
        set(gca, 'YDir', 'reverse');
    end
    plot.subtitle(D.datestr, 'FontSize', 18);
    
    set(gcf, 'Position', [100 100 650 600]);
    set(gcf, 'PaperPosition', get(gcf, 'Position'));

end
