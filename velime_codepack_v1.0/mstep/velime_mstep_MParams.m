function estParams = velime_mstep_MParams(E_X_posterior, COV_X_posterior, C, const)

% Velocity feedback is not maintained in E_X, so first we concatenate it
% into E_X for this portion of code only.  It might be cleaner to add it in
% permanently, but then we'd carry around 2 timesteps of position feedback.

C_v_idx = [3 4]; % MAGIC NUMBERS
vDim = 2; % MAGIC NUMBERS
V_idx = const.x_idx(3:4,:); % MAGIC NUMBERS
EVDim = numel(V_idx);

E_V_posterior = [C(C_v_idx,:); E_X_posterior(V_idx,:)];

shift_idx = (vDim+1):(EVDim + vDim);
COV_V_posterior(shift_idx,shift_idx,:) = COV_X_posterior(V_idx,V_idx,:);

% Same as below:
% COV_V_posterior = [zeros(vDim, EVDim + vDim, const.T);
%    zeros(EVDim,vDim, T) COV_X_posterior(V_idx,V_idx,:)];

const.xDim = const.vDim; % overwrite since we are leveraging fastfmc code
estParams = fastfmc_mstep_MParams(E_V_posterior, COV_V_posterior, const);
estParams.V = mean(estParams.V)*ones(const.vDim,1);