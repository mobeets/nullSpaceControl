function [mdlErrs, cErrs, result, by_trial] = imeErrs(U, Y, Xtarget, ...
    estParams, TARGET_RADIUS, T_START)

    basedir = pwd;
    cd('velime_codepack_v1.0/');
    result = velime_evaluate(U, Y, Xtarget, estParams, ...
        'TARGET_RADIUS', TARGET_RADIUS, 'T_START', T_START);

    errs = cell(1,numel(U));
    for ii = 1:numel(U)
        P_t = Y{ii};
        P_tp1 = P_t(:,T_START+1:end);
        P_t = P_t(:,T_START:end-1);
        errs{ii} = angular_error_from_perimeter(P_t, P_tp1, ...
            Xtarget{ii}, TARGET_RADIUS);
    end
    cd(basedir);
    by_trial.cErrs = errs;
    by_trial.mdlErrs = result.trial_error_angles_from_perimeter;
    cErrs = abs(cell2mat(errs));
    mdlErrs = abs(cell2mat(result.trial_error_angles_from_perimeter));

end
