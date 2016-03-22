% Probabilistic Framework for Internal Model Estimation
% 
% All notation here matches implementation time indexing.
%
% The probabilistic model is:
% p(t-tau) = p^{true}(t-tau)     [dummy variable]
% v(t-tau-1) = v^{true}(t-tau-1) [dummy variable]
% p(t) | p(t-1),v(t-1) ~ N(p(t-1) + v(t-1), W_p)**
% v(t)|v(t-1),u(t+1) ~ N(A*v(t-1) + B*u(t+1) + b0, W_v)
% G(t) | p(t),v(t) ~ N(p(t)+alpha_t*v(t),R)
%
% ** Units on velocity are distance/timestep (so we don't need dt)
%
% Example graphical model, tau=2 (state transitions are more specific than
% indicated, see equations above):
%
%                u(t-1)          u(t)         u(t+1)
%                   |             |             |
%                   V             V             V
% [y_p(t-2); -> [x_p(t-2); -> [x_p(t-1); -> [x_p(t); -> G(t)
%  y_v(t-3)]     x_v(t-2)]     x_v(t-1)]     x_v(t)]
%
% Time indexing relative to online decoders can be confusing.  I've chosen
% the above notation for implementation convenience.  The model can recover
% the structure of standard online decoders (see below) because the model 
% and the decoders all update with p(t) = f(p(t-1),u(t)).
% Model: p(t) = p(t-1) + v(t-1)*dt + noise
%             = p(t-1) + A*v(t-2) + B*u(t) + b0 + noise
%             = f(p(t-1),u(t)) [also a function of additional u's]
%
% This model is suitable for capturing PVA- and KF-based BMI control:
% 1)PVA: 
%       p(t) = p(t-1) + v(t)*dt
%       v(t) = B*u(t) + b0
% 2)Velocity KF: 
%       p(t) = p(t-1) + v(t)*dt
%       v(t) = M1*v(t-1) + M2*u(t) + m0
% 3)Position+Velocity KF: 
%       [p(t); v(t)]= M1*[p(t-1); v(t-1)] + M2*u(t) + m0