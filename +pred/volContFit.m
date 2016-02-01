function Z = volContFit(D, addPrecursor, useL)
    if nargin < 3
        useL = false;
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
        decoder = B2.fDecoder;
        if addPrecursor
            Zpre(t,:) = pred.randZIfNearbyTheta(B2.thetas(t) + 180, B1, nan, true);
            decoder.M0 = decoder.M0 + decoder.M2*Zpre(t,:)';
        end
        
        if useL > 2 % meet kinematics, minimize to baseline
            oldDec = decoder;
            decoder.M2 = decoder.M2*RB1;
            z = pred.quadFireFit(B2, t, [], decoder, false);
            if isempty(z)
                Zvol(t,:) = pred.rowSpaceFit(B2, oldDec, NB1, RB1, t);
                continue;
            end
            Zvol(t,:) = RB1*z;
        else
            Zvol(t,:) = pred.rowSpaceFit(B2, decoder, NB1, RB1, t);
        end
    end
    Z = Zvol + Zpre;
    
end
