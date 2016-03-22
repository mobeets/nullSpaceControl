function LLi  = velime_LL(U,Y,Xtarget, estParams, t_start)

[C,G,const] = velime_assemble_data(U,Y,Xtarget,estParams.TAU);

R = diag(estParams.R);
alpha = estParams.alpha;

gDim = const.gDim;
llconst = gDim*log(2*pi);
half = 1/2;

x_pt_idx = const.x_pt_idx;
x_vt_idx = const.x_vt_idx;

% Step 1: Put together E(x_-{tau}^t,...,x_0^t, u_t | x_-{tau}^t, u_{t-tau+1},...u_{t-1})
% and cov(x_-{tau}^t,...,x_0^t, u_t | x_-{tau}^t, u_{t-tau+1},...u_{t-1})
[E_X, SIGMA11, E_TARG] = velime_prior_expectation(C, estParams);

x2_minus_mu2 = G - E_TARG;

% Sigma_22 = cov(x^{target}_t | x_-{tau}^t, u_{t-tau+1},...u_t)
% SIGMA12 = cov([x_-{tau+1}^t;...;x_0^t], x^{target}_t | x_-{tau}^t, u_{t-tau+1},...u_{t-1})

T = size(E_X,2);

% Fast code
SIGMA_pp = SIGMA11(x_pt_idx,x_pt_idx); % cov(p_t^t)
SIGMA_pv = SIGMA11(x_pt_idx,x_vt_idx); % cov(p_t^t,v_t^t)
SIGMA_vp = SIGMA11(x_vt_idx,x_pt_idx); % cov(v_t^t,p_t^t)
SIGMA_vv = SIGMA11(x_vt_idx,x_vt_idx); % cov(v_t^t)

% Build up terms to SIGMA22
term1 = repmat(SIGMA_pp(:),1,T);
term2 = bsxfun(@times,repmat(SIGMA_pv(:)+SIGMA_vp(:),1,T),alpha);
term3 = bsxfun(@times,repmat(SIGMA_vv(:),1,T),alpha.^2);

SIGMA22s = bsxfun(@plus,term1 + term2 + term3, R(:));
% To recover SIGMA22: reshape(SIGMA22s(:,1),gDim,gDim)

detSIGMA22s = SIGMA22s(1,:).*SIGMA22s(4,:)-SIGMA22s(2,:).*SIGMA22s(3,:);
logdetSIGMA22s = log(detSIGMA22s);

inv_term = [SIGMA22s(4,:); -SIGMA22s(2,:); -SIGMA22s(3,:); SIGMA22s(1,:)];
invSIGMA22s = bsxfun(@times,inv_term,1./detSIGMA22s);

XcXc = [x2_minus_mu2(1,:).^2
    x2_minus_mu2(1,:).*x2_minus_mu2(2,:)
    x2_minus_mu2(1,:).*x2_minus_mu2(2,:)
    x2_minus_mu2(2,:).^2];

if exist('t_start','var')
    T_trial = cellfun(@length,const.trial_map);
    original_t_start = estParams.TAU+2;
    
    if t_start<original_t_start
        error('t_start<original_t_start');
    end
    
    % t_start is nominally (TAU+2).  If user specifies larger t_start for
    % LL computation, then decrease T accordingly.
    T_adjusted = sum(max(0,T_trial-(t_start-original_t_start)));
    trial_map_keep = cellfun(@(t)(t((t_start-original_t_start+1):end)),const.trial_map,'uniformoutput',false);
    idx_keep = cell2mat(trial_map_keep);
    
    LLi = -half*(T_adjusted*llconst + sum(logdetSIGMA22s(:,idx_keep) + sum(XcXc(:,idx_keep).*invSIGMA22s(:,idx_keep),1)));
else
    LLi = -half*(T*llconst + sum(logdetSIGMA22s + sum(XcXc.*invSIGMA22s,1)));
end