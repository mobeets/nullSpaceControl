function [C,G,const] = velime_assemble_data(U, Y, TARGETS, TAU, t_start)
% [C,G,const] = velime_assemble_data(U, Y, TARGETS, TAU)
% [C,G,const] = velime_assemble_data(U, Y, TARGETS, TAU, t_start)

if exist('t_start','var')
    if t_start<TAU+2
        error('t_start must be >= TAU+2');
    end
else
    t_start = TAU+2;
end

num_trials = numel(U);

% Construct constant matrix C where column c_t = [y^p_{t-tau}; y^v_{t-tau-1}; u_{t-tau+1}; ... ; u_{t+1}]
% Construct observation matrix G where column g_t = target position from appropriate trial

T = cellfun(@(u)(size(u,2)),U);
dt = 1; % 1 timestep

yPosIdx = 1:2;

xDim = 4;
gDim = 2; 
uDim = mode(cellfun(@(u)(size(u,1)),U));
EXDim = (TAU+1)*xDim;

% Write this, give xMap: one string for each set of indices into x
[K, x_idx] = velime_x_index(TAU,xDim);

T_valid = sum(max(0,T-(TAU+2)));
C = zeros(xDim + (TAU+1)*uDim,T_valid);
G = zeros(gDim,T_valid);

idx = 1;
for trialNo = 1:num_trials
    const.trial_map{trialNo} = idx:((idx-1)+T(trialNo)-t_start);
    vel_trial = [nan(2,1) diff(Y{trialNo},1,2)/dt];
    for t = t_start:T(trialNo)-1
        U_seq = U{trialNo}(:,t-TAU+1:t+1);
        
        % Available from feedback: pos(t-tau) and 
        % vel(t-tau) = pos(t-tau)-pos(t-tau-1)
        % isequal(vel_trial(:,t-TAU),Y{trialNo}(yPosIdx,t-TAU)-Y{trialNo}(yPosIdx,t-TAU-1))
        
        C(:,idx) = [Y{trialNo}(yPosIdx,t-TAU); vel_trial(:,t-TAU); U_seq(:)];
        if any(isnan(C(:,idx)))
            x=1;
        end
        G(:,idx) = TARGETS{trialNo}(:,1);
        idx = idx + 1;
    end
end

const.T = T_valid;
const.dt = dt;
const.uDim = uDim;
const.gDim = gDim;
const.xDim = xDim;
const.pDim = 2;
const.vDim = 2;
const.EXDim = EXDim;
const.K = K;
const.x_idx = x_idx;
const.x_pt_idx = EXDim-3:EXDim-2;
const.x_vt_idx = EXDim-1:EXDim;

% Here TAU+1 gives the number of timesteps worth of u's that contribute to
% each latent state chain, x.
const.Urep = zeros(uDim,T_valid*(TAU+1));
for j = 1:TAU+1
    % j=1, xDim=4 --> 5:(4+uDim)
    % j=2, xDim=4 --> (5+uDim):(4+2*uDim)
    idx_u = (xDim + 1 + uDim*(j-1)):(xDim + uDim*j); % rows
    idx_t = (T_valid*(j-1)+1):T_valid*j; % columns
    const.Urep(:,idx_t) = C(idx_u,:);
end

sum_Urep = sum(const.Urep,2);
const.sum_U1_U1 =  [const.Urep*const.Urep' sum_Urep;
    sum_Urep' T_valid*(TAU+1)];