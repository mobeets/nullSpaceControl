function [Z, Zpre, Zvol] = volContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'addPrecursor', true, ...
        'useL', false, 'scaleVol', 1, 'obeyBounds', true, ...
        'scaleBounds', true, 'thetaTol', 15);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    if opts.useL == 1
        ys = B1.latents;
        [~,~,V] = svd(ys);
        RB1 = V(:,1:2);
        NB1 = tools.getNulRowBasis(RB1');
    elseif opts.useL > 1
        RB1 = eye(size(B1.(opts.decoderNm).M2,2), opts.useL);
        NB1 = tools.getNulRowBasis(RB1');
    else % volitional space = row space of M2
        RB1 = B1.(opts.decoderNm).RowM2;
        NB1 = B1.(opts.decoderNm).NulM2;
    end
    
    % find bounds given by B1 activity
    isOutOfBounds = pred.boundsFcn(B1.latents);
    
    [nt, nn] = size(B2.latents);

    Zpre = zeros(nt,nn);
    Zvol = nan(nt,nn);
    d = 0;
    % need to set x(0) to set Z(1)
    for t = 1:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta

        [Zpre(t,:), Zvol(t,:)] = newSample(t, B1, B2, NB1, RB1, opts);
        
        if opts.obeyBounds % try scaling down volitional until within bnds
            c = 0;
            while isOutOfBounds(Zpre(t,:) + Zvol(t,:)/opts.scaleVol) && c < 10
                if opts.scaleBounds
                    Zvol(t,:) = Zvol(t,:)/(c+1);
                else
                    [Zpre(t,:), Zvol(t,:)] = newSample(t, B1, B2, NB1, ...
                        RB1, opts);
                end
                c = c + 1;
            end
            if c < 10
                d = d + 1;
            else
                Zpre(t,:) = nan(size(Zpre(t,:)));
                Zvol(t,:) = nan(size(Zvol(t,:)));
            end
        end
    end
    Z = Zvol/opts.scaleVol + Zpre;
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ' volitional samples to lie within bounds']);
    end
end

function [Zpre, Zvol] = newSample(t, B1, B2, NB1, RB1, opts)
    dec = B2.(opts.decoderNm);
    if opts.addPrecursor
        Zpre = pred.randZIfNearbyTheta(B2.thetas(t), B1, ...
            opts.thetaTol, true);
        dec.M0 = dec.M0 + dec.M2*Zpre';
    end

    if opts.useL > 2 % meet kinematics, minimize to baseline
%         Zvol(t,:) = solveInBounds(B2, t, decoder, RB1, B1, Zpre(t,:));
        dec.M2 = dec.M2*RB1;
        z = pred.quadFireFit(B2, t, [], dec, false);
        Zvol = RB1*z;
    else
        Zvol = pred.rowSpaceFit(B2, dec, NB1, RB1, t);
    end
end

% 
% function x = solveInBounds1(Blk, t, decoder, RB, Blk0, zPre)
%     x1 = Blk.vel(t,:)';
%     x0 = Blk.velPrev(t,:)';
%     Ac = decoder.M1;
%     Bc = decoder.M2;
%     cc = decoder.M0;
%     
%     cc = cc + Bc*zPre';
%     Aeq = Bc*RB;
%     beq = x1 - Ac*x0 - cc;
%     
%     % combine all inequality constraints
%     lb = min(Blk0.latents) - zPre;
%     ub = max(Blk0.latents) - zPre;
%     A = [-RB; RB];
%     b = [-lb'; ub'];
%     
%     z0 = Aeq \ beq;
%     if all(A*z0 < b)
%         x = RB*z0 + zPre';
%         return;
%     end
%     z0 = zeros(size(A,2),1);
%     options = optimset('Display', 'off');
%     
%     % find closest to solution to obeying cursor that stays in bounds
%     obj = @(x) norm(beq - Aeq*x);
%     x = zPre' + RB*fmincon(obj, z0, A, b, [], [], [], [], [], options);
% end
% 
% function x = solveInBounds2(Blk, t, decoder, RB, Blk0, zPre)
%     x1 = Blk.vel(t,:)';
%     x0 = Blk.velPrev(t,:)';
%     Ac = decoder.M1;
%     Bc = decoder.M2;
%     cc = decoder.M0;
%     
%     cc = cc + Bc*zPre';
%     Aeq = Bc*RB;
%     beq = x1 - Ac*x0 - cc;
%     
%     % combine all inequality constraints
%     lb = min(Blk0.latents) - zPre;
%     ub = max(Blk0.latents) - zPre;
%     A = [-RB; RB];
%     b = [-lb'; ub'];
%     
%     z0 = Aeq \ beq;
%     options = optimset('Display', 'off');
%     
%     % find minimum-norm solution obeying cursor and bounds
%     obj = @(x) norm(zPre' + RB*x);
%     x = zPre' + RB*fmincon(obj, z0, A, b, Aeq, beq, [], [], [], options);
% 
% end
% 
% function x = solveInBounds(Blk, t, decoder, RB, Blk0, zPre)
%     x1 = Blk.vel(t,:)';
%     x0 = Blk.velPrev(t,:)';
%     Ac = decoder.M1;
%     Bc = decoder.M2;
%     cc = decoder.M0;
%     
%     % combine all inequality constraints
%     lb = min(Blk0.latents);
%     ub = max(Blk0.latents);
%     A = [-RB; RB];
%     b = [-lb'; ub'];
%     
%     % check if we already have valid solution
%     ccOG = cc;
%     cc = cc + Bc*zPre';
%     Aeq = Bc*RB;
%     beq = x1 - Ac*x0 - cc;
%     z0 = Aeq \ beq;
%     if all(A*z0 + [zPre'; zPre'] < b)
%         x = RB*z0 + zPre';
%         return;
%     else
%         cc = ccOG;
%         Aeq = Bc*RB;
%         beq = x1 - Ac*x0 - cc;
%     end
% 
%     % find closest solution to precursor activity that obeys cursor and
%     % bounds
%     options = optimset('Display', 'off');
%     obj = @(x) norm(zPre' - RB*x);
%     x = RB*fmincon(obj, z0, A, b, Aeq, beq, [], [], [], options);
%     
% %     nd = size(Aeq, 2);
% %     H = eye(nd);
% %     A = -eye(nd);
% %     b = zeros(nd,1);
% %     [z, ~, exitflag] = quadprog(H, f, A, b, Aeq, beq, ...
% %         lb, ub, [], options);
% 
% end
