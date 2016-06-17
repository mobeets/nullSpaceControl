function [mdlErrs, cErrs, result, by_trial] = imeErrs(U, Y, Xtarget, ...
    estParams, TARGET_RADIUS, T_START)

%     [E_P, ~] = velime_extract_prior_whiskers(U, Y, Xtarget, estParams);
    
    errs = cell(1,numel(U));    
    for ii = 1:numel(U)
        P_t = Y{ii};
        P_tp1 = P_t(:,T_START+1:end);
        P_t = P_t(:,T_START:end-1);
        [es, ths] = angular_error_from_perimeter(P_t, P_tp1, ...
            Xtarget{ii}, TARGET_RADIUS);
        errs{ii} = es;
        
%         P_t = E_P{ii}(end-1:end,1:size(Y{ii},2));
%         P_tp1 = P_t(:,T_START+1:end);
%         P_t = P_t(:,T_START:end-1);
%         es = angular_error_from_perimeter(P_t, P_tp1, ...
%             Xtarget{ii}, TARGET_RADIUS);
%         errs2{ii} = es;
    end

    by_trial.cErrs = errs;
    result = velime_evaluate(U, Y, Xtarget, estParams, ...
        'TARGET_RADIUS', TARGET_RADIUS, 'T_START', T_START);    
    by_trial.mdlErrs = result.trial_error_angles_from_perimeter;
    cErrs = abs(cell2mat(errs));    
    mdlErrs = abs(cell2mat(result.trial_error_angles_from_perimeter));
    
%     mdlErrs = abs(cell2mat(errs2));
%     by_trial.mdlErrs = errs2;

end
