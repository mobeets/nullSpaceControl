function [Z, Zpre, Zvol] = volContFit(D, addPrecursor, useL, scaleVol)
    if nargin < 3
        useL = false;
    end
    if nargin < 4
        scaleVol = 1;
    end

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    if useL == 1
        ys = B1.latents;
        [~,~,V] = svd(ys);
        RB1 = V(:,1:2);
        NB1 = tools.getNulRowBasis(RB1');
    elseif useL > 1
        RB1 = eye(size(B1.fDecoder.M2,2), useL);
        NB1 = tools.getNulRowBasis(RB1');
    else % volitional space = row space of M2
        RB1 = B1.fDecoder.RowM2;
        NB1 = B1.fDecoder.NulM2;
    end

    [nt, nn] = size(B2.latents);

    Zpre = zeros(nt,nn);
    Zvol = nan(nt,nn);
    % need to set x(0) to set Z(1)
    for t = 1:nt
        % sample Z uniformly from times t in T1 where theta_t is
        % within 15 degs of theta
        if mod(t, 100) == 0
            disp([num2str(t) ' of ' num2str(nt)]);
        end
        decoder = B2.fDecoder;
        
        Zpre(t,:) = pred.randZIfNearbyTheta(B2.thetas(t) + 180, B1, nan, true);
        Zvol(t,:) = solveInBounds2(B2, t, decoder, RB1, B1, Zpre(t,:));
        Zpre(t,:) = zeros(1,nn);
        continue;
        
        if addPrecursor
            Zpre(t,:) = pred.randZIfNearbyTheta(B2.thetas(t) + 180, B1, nan, true);
%             Zpre(t,:) = pred.randZIfNearbyMinTheta(B2.thetas(t) + 180, B1, 10);
            decoder.M0 = decoder.M0 + decoder.M2*Zpre(t,:)';
        end
        
        if useL > 2 % meet kinematics, minimize to baseline
            Zvol(t,:) = solveInBounds(B2, t, decoder, RB1, B1, Zpre(t,:));
%             decoder.M2 = decoder.M2*RB1;            
%             z = pred.quadFireFit(B2, t, [], decoder, false);
%             Zvol(t,:) = RB1*z;
        else
            Zvol(t,:) = pred.rowSpaceFit(B2, decoder, NB1, RB1, t);
        end        
    end
    Z = Zvol/scaleVol + Zpre;
    
end

function x = solveInBounds1(Blk, t, decoder, RB, Blk0, zPre)
    x1 = Blk.vel(t,:)';
    x0 = Blk.velPrev(t,:)';
    Ac = decoder.M1;
    Bc = decoder.M2;
    cc = decoder.M0;
    
    cc = cc + Bc*zPre';
    Aeq = Bc*RB;
    beq = x1 - Ac*x0 - cc;
    
    % combine all inequality constraints
    lb = min(Blk0.latents) - zPre;
    ub = max(Blk0.latents) - zPre;
    A = [-RB; RB];
    b = [-lb'; ub'];
    
    z0 = Aeq \ beq;
    if all(A*z0 < b)
        x = RB*z0 + zPre';
        return;
    end
    z0 = zeros(size(A,2),1);
    options = optimset('Display', 'off');
    
    % find closest to solution to obeying cursor that stays in bounds
    obj = @(x) norm(beq - Aeq*x);
    x = zPre' + RB*fmincon(obj, z0, A, b, [], [], [], [], [], options);
end

function x = solveInBounds2(Blk, t, decoder, RB, Blk0, zPre)
    x1 = Blk.vel(t,:)';
    x0 = Blk.velPrev(t,:)';
    Ac = decoder.M1;
    Bc = decoder.M2;
    cc = decoder.M0;
    
    cc = cc + Bc*zPre';
    Aeq = Bc*RB;
    beq = x1 - Ac*x0 - cc;
    
    % combine all inequality constraints
    lb = min(Blk0.latents) - zPre;
    ub = max(Blk0.latents) - zPre;
    A = [-RB; RB];
    b = [-lb'; ub'];
    
    z0 = Aeq \ beq;
    options = optimset('Display', 'off');
    
    % find minimum-norm solution obeying cursor and bounds
    obj = @(x) norm(zPre' + RB*x);
    x = zPre' + RB*fmincon(obj, z0, A, b, Aeq, beq, [], [], [], options);

end

function x = solveInBounds(Blk, t, decoder, RB, Blk0, zPre)
    x1 = Blk.vel(t,:)';
    x0 = Blk.velPrev(t,:)';
    Ac = decoder.M1;
    Bc = decoder.M2;
    cc = decoder.M0;
    
    % combine all inequality constraints
    lb = min(Blk0.latents);
    ub = max(Blk0.latents);
    A = [-RB; RB];
    b = [-lb'; ub'];
    
    % check if we already have valid solution
    ccOG = cc;
    cc = cc + Bc*zPre';
    Aeq = Bc*RB;
    beq = x1 - Ac*x0 - cc;
    z0 = Aeq \ beq;
    if all(A*z0 + [zPre'; zPre'] < b)
        x = RB*z0 + zPre';
        return;
    else
        cc = ccOG;
        Aeq = Bc*RB;
        beq = x1 - Ac*x0 - cc;
    end

    % find closest solution to precursor activity that obeys cursor and
    % bounds
    options = optimset('Display', 'off');
    obj = @(x) norm(zPre' - RB*x);
    x = RB*fmincon(obj, z0, A, b, Aeq, beq, [], [], [], options);
    
%     nd = size(Aeq, 2);
%     H = eye(nd);
%     A = -eye(nd);
%     b = zeros(nd,1);
%     [z, ~, exitflag] = quadprog(H, f, A, b, Aeq, beq, ...
%         lb, ub, [], options);

end



