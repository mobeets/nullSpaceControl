function allErrorByKin(D, Hs)

    ncols = 2; nrows = 2;
    subplot(ncols, nrows, 1);
    plot.errorByKin(Hs, 'errOfMeansByKin');
    subplot(ncols, nrows, 2);
    plot.errorByKin(Hs, 'covErrorByKin');
    subplot(ncols, nrows, 3);
    plot.errorByKin(Hs, 'covErrorShapeByKin');
    subplot(ncols, nrows, 4);
    plot.errorByKin(Hs, 'covErrorOrientByKin');
    plot.subtitle(D.datestr);
    set(gcf, 'Position', [100 100 750 600]);
%     set(gcf, 'PaperPosition', get(gcf, 'Position'));
end
