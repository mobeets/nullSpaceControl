function result = velime_evaluate(U, Y, TARGS, estParams, varargin)
% result is a struct with the following fields:
%
% trial_error_angles
%   cell array where each cell contains a non-negative angular error for
%   each timestep in that trial
% error_angle
%   an average of all of the anglular errors in trial_error_angles
% trial_avg_abs_error_angles
%   average value for each trial


TARGET_RADIUS = .016;
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
    G_t = G(:,trial_indices);
    unique_G = unique(G_t','rows')';
    if size(unique_G,2)==1
        error_angles_from_perimeter{trialNo} = angular_error_from_perimeter(P_t,P_tp1,unique_G,TARGET_RADIUS);
    else
        for t = 1:length(trial_indices)
            error_angles_from_perimeter{trialNo}(1,t) = angular_error_from_perimeter(P_t(:,t),P_tp1(:,t),G_t(:,t),TARGET_RADIUS);
        end
    end
end

result.trial_error_angles_from_perimeter = error_angles_from_perimeter;
result.error_angle_from_perimeter = mean(abs(cell2mat(error_angles_from_perimeter)));
result.trial_avg_abs_error_angles_from_perimeter = cellfun(@(a)(mean(abs(a))),error_angles_from_perimeter);