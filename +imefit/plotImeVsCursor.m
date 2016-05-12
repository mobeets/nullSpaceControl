function plotImeVsCursor(D, bind, mdlErrs, cursorErrs)

    plot.init;
    plot(mdlErrs, cursorErrs, '.');
    xlabel('internal model errors (degrees)');
    ylabel('cursor errors (degrees)');
    title([D.datestr ' Blk' num2str(bind)]);
    xlim([0 180]); ylim(xlim);
    set(gca, 'XTick', 0:45:180);
    set(gca, 'YTick', 0:45:180);

    plot.init;
    xs = 0:180;
    ys = 0:180;
    ns = hist3([mdlErrs; cursorErrs]', {xs, ys});
    imagesc(xs, ys, log(ns)');
    xlabel('internal model errors (degrees)');
    ylabel('cursor errors (degrees)');
    axis image;
    title([D.datestr ' Blk' num2str(bind)]);
    set(gca, 'XTick', 0:45:180);
    set(gca, 'YTick', 0:45:180);

    [mean(cursorErrs) mean(mdlErrs)]

end
