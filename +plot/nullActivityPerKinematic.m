function nullActivityPerKinematic(lts, thetas, cnts, doScatter, doMean, clr)
    if nargin < 4
        doScatter = true;
    end
    if nargin < 5
        doMean = true;
    end
    if nargin < 6
        clr = [0.8 0.8 0.8];
    end
    
    grps = score.thetaGroup(thetas, cnts);
    npanels = numel(cnts);
    nps_c = ceil(sqrt(npanels));
    nps_r = round(npanels/nps_c);
    xs = 1:size(lts,2);
    
    ymax = max(abs(lts(:)));
    ymax = 2;
    if doScatter
        ymax = 7;
    end
    for ii = 1:npanels
        subplot(nps_c, nps_r, ii);
        set(gca, 'FontSize', 14);
        hold on;
        ys0 = lts(grps == cnts(ii),:);
        if doScatter
            for jj = xs 
                scatter(xs(jj)*ones(size(ys0,1),1), ys0(:,jj), '.');
            end
        end
        if doMean
            plot(xs, mean(ys0), 'color', clr, 'LineWidth', 3);
            scatter(xs, mean(ys0,1), 50, clr, 'MarkerFaceColor', clr);            
        end
        ylim([-ymax ymax]);
        plot(xlim, [0 0], '--', 'Color', [0.5 0.5 0.5]);
        set(gca, 'XTick', xs);
        set(gca, 'XTickLabel', xs);
        xlim([0.5 max(xs)+0.5]);
        ylabel(['\theta=' num2str(cnts(ii))]);
    end
    xlabel('Nul(.) column index');
    set(gcf, 'color', 'w');

end
