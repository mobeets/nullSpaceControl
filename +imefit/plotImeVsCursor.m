function plotImeVsCursor(D, bind, U, Y, Xtarget, estParams, TARGET_RADIUS, T_START)
    
    basedir = pwd;
    cd('velime_codepack_v1.0/');
    result = velime_evaluate(U, Y, Xtarget, estParams, ...
        'TARGET_RADIUS', TARGET_RADIUS, 'T_START', T_START);

    %% Compare to cursor error

    errs = cell(1,numel(U));
    for ii = 1:numel(U)
        P_t = Y{ii};
        P_tp1 = P_t(:,T_START+1:end);
        P_t = P_t(:,T_START:end-1);
        errs{ii} = angular_error_from_perimeter(P_t, P_tp1, ...
            Xtarget{ii}, TARGET_RADIUS);
    end
    cd(basedir);

    figure; set(gcf, 'color', 'w'); hold on; set(gca, 'FontSize', 14);
    cursorErrs = abs(cell2mat(errs));
    mdlErrs = abs(cell2mat(result.trial_error_angles_from_perimeter));
    plot(mdlErrs, cursorErrs, '.');
    xlabel('internal model errors (degrees)');
    ylabel('cursor errors (degrees)');
    title([D.datestr ' Blk' num2str(bind)]);

    figure; set(gcf, 'color', 'w'); hold on; set(gca, 'FontSize', 14);
    xs = 1:60;%round(max(mdlErrs));
    ys = 1:60;%round(max(cursorErrs));
    ns = hist3([mdlErrs; cursorErrs]', {xs, ys});
    imagesc(xs, ys, log(ns)');
    xlabel('internal model errors (degrees)');
    ylabel('cursor errors (degrees)');
    axis image;
    title([D.datestr ' Blk' num2str(bind)]);

    [mean(cursorErrs) mean(mdlErrs)]

end
