function result = velime_whiskerLengths(U, Y, TARGS, estParams, varargin)


T_START = estParams.TAU + 2;
rem = assignopts(who,varargin);
if ~isempty(rem)
    warning('Optional input arguments not assigned: ');
    disp(a);
end

[C,G,const] = velime_assemble_data(U,Y,TARGS,estParams.TAU);
E_X = velime_prior_expectation(C, estParams);

N_trials = numel(const.trial_map);
error_angles_from_perimeter = cell(1,N_trials);
for trialNo = 1:N_trials
    trial_indices = const.trial_map{trialNo};
    
    % Adjust for t_start
    original_t_start = estParams.TAU+2;
    if T_START<original_t_start
        error('t_start<original_t_start');
    end
    trial_indices = trial_indices((T_START-original_t_start+1):end);
    
    P_t = E_X(const.x_pt_idx,trial_indices);
    V_t = E_X(const.x_vt_idx,trial_indices);
    P_tp1 = P_t + V_t*const.dt;
    
    result(trialNo).whiskerTipLengths = sqrt(sum((P_tp1-P_t).^2));
end