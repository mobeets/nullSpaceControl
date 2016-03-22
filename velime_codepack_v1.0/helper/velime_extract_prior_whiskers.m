function [E_P, E_V] = velime_extract_prior_whiskers(U, Y, TARGS, estParams, varargin)

T_START = estParams.TAU + 2;
rem = assignopts(who,varargin);
if ~isempty(rem)
    warning('Optional input arguments not assigned: ');
    disp(a);
end

[C,G,const] = velime_assemble_data(U,Y,TARGS,estParams.TAU);
E_X = velime_prior_expectation(C, estParams);

N_trials = numel(const.trial_map);
pIdx = const.x_idx(1:const.pDim,:);
vIdx = const.x_idx(const.pDim+1:const.xDim,:);
for trialNo = 1:N_trials
    trial_indices = const.trial_map{trialNo};
    E_P{trialNo} = [nan(numel(pIdx),T_START) E_X(pIdx,trial_indices)];
    E_V{trialNo} = [nan(numel(vIdx),T_START) E_X(vIdx,trial_indices)];
    
    % P_t = E_X(const.x_pt_idx,trial_indices);
    % V_t = E_X(const.x_vt_idx,trial_indices);
    % P_tp1 = P_t + V_t*const.dt;
end