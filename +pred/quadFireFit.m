function [z, u] = quadFireFit(x1, x0, f, A2, B2, c2)

    % Each u(t) in U is solution (using quadprog) to:
    %   min_u(t) norm(u(t))^2
    %      s.t.
    %         (1) u(t) ? 0
    %         (2) x1 = A2*x0 + B2*z(u(t)) + c2
    % i.e.
    %   min_u (1/2)*u'*H*u + f'*u
    %      s.t.
    %         (1) A*u ? b
    %         (2) Aeq*u = beq
    %

    nd = numel(f);
    H = eye(nd);
    A = -eye(nd);
    b = zeros(nd,1);
    
    Aeq = []; % s.t. Aeq*u = B2*z(u); might need to add term to beq
    beq = x1 - A2*x0 - c2;
    u = quadprog(H, f, A, b, Aeq, beq);

    % Z = fastfa_estep(U, estParams);
    % or must the following be done point-wise?
    z = L'*((L*L' + Phi) \ (Sig \ (u - eta))); % Eq. 5
    
end
