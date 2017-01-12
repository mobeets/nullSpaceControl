function [z, isRelaxed] = quadFireFit(Blk, t, f, decoder, fitInLatent, ...
    lb, ub, Dc)
% 
% Each u(t) in U is solution (using quadprog) to:
%   min_u norm(u + f)^2
%      s.t.
%         (1) u ? 0
%         (2) x1 = A2*x0 + B2*u + c2
%         (3) lb ? u ? ub
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

    if numel(lb) > 0
        nd = numel(lb);
    else
        nd = size(Bc, 2);
    end
    H = eye(nd);
    A = -eye(nd); % A,b enforce non-negativity of spike solution
    b = zeros(nd,1);
    
%     A = []; b = []; lb = []; ub = [];
    
    if fitInLatent
        A = [];
        b = [];
    end
    
    Aeq = Bc;
    beq2 = x1 - Ac*x0 - cc;
    beq = Aeq*Blk.latents(t,:)';
    % beq2 won't work with IME currently; beq is a more robust definition

    if ~fitInLatent
        % update Aeq,beq so that our spike solutions, after 
        % converting to inferred latents, satisfy the kinematics 
        % constraints under the mapping in latents
        [~, beta] = tools.convertRawSpikesToRawLatents(Dc, zeros(1,nd));
        mu = Dc.spikeCountMean;
        Aeq = Aeq*beta;
        beq = beq + Aeq*mu';
    end

    options = optimset('Algorithm', 'interior-point-convex', ...
        'Display', 'off');
    isRelaxed = false;
    try
        [z, ~, exitflag] = quadprog(H, f, A, b, Aeq, beq, ...
            lb, ub, [], options);
    catch
        z = nan(1,nd);
        warning('error in quadFireFit');
        return;
    end
    if ~exitflag
        warning('quadprog optimization incomplete, but stopped.');
    end
    if isempty(z)
%         warning('Relaxing non-negative constraint and bounds.');
        z = quadprog(H, f, [], [], Aeq, beq, ...
            [],[],[], options);
        isRelaxed = true;
    end
    
end
