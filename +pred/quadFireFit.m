function [z, isRelaxed] = quadFireFit(Blk, t, f, decoder, fitInLatent, lb, ub)
% 
% Each u(t) in U is solution (using quadprog) to:
%   min_u norm(u + f)^2
%      s.t.
%         (1) u ? 0
%         (2) x1 = A2*x0 + B2*u + c2
% i.e.
%   min_u (1/2)*u'*H*u + f'*u
%      s.t.
%         (1) A*u ? b
%         (2) Aeq*u = beq
%
    if nargin < 6
        lb = [];
        ub = [];
    end
    x0 = Blk.vel(t,:)';
    x1 = Blk.velNext(t,:)';

    Ac = decoder.M1;
    Bc = decoder.M2;
    cc = decoder.M0;
        
    nd = size(decoder.M2, 2);
    H = eye(nd);
    A = -eye(nd);
    b = zeros(nd,1);
    if fitInLatent
        %  % L'*L where L = diag(sigma)*L from FactorParams
%         H = []; % ALinv'*ALinv
        A = []; % -ALinv
        b = []; % mu
    end
    
    Aeq = Bc; % s.t. Aeq*u = Bc*z(u); might need to add term to beq
    beq = x1 - Ac*x0 - cc;
    
    options = optimset('Algorithm', 'interior-point-convex', ...
        'Display', 'off');
    [z, ~, exitflag] = quadprog(H, f, A, b, Aeq, beq, ...
        lb, ub, [], options);
    if ~exitflag
        warning('quadprog optimization incomplete, but stopped.');
    end
    isRelaxed = false;
    if isempty(z)
%         warning('Relaxing non-negative constraint and bounds.');
        z = quadprog(H, f, [], [], Aeq, beq, ...
            [],[],[], options);
        isRelaxed = true;
    end
    
end
