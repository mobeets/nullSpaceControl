function angErrorByTrial(D, doAbs, nbins)    
    if nargin < 2
        doAbs = false;
    end
    if nargin < 3
        nbins = 200;
    end
    
    hold on;
    ys1 = D.blocks(1).angError;
    ys2 = D.blocks(2).angError;
    if doAbs
        ys1 = abs(ys1); ys2 = abs(ys2);
    end
    plot(smooth(ys1, nbins));
    plot(smooth(ys2, nbins));
    set(gca, 'FontSize', 14);
    set(gcf, 'color', 'w');
    xlabel('time since perturbation');
    ylbl = 'angular error';
    if doAbs
        ylbl = ['abs(' ylbl ')'];
    end
    ylabel(ylbl);
    legend('intuitive', 'perturbation');
    title(D.datestr);

end
