function cursorMovementByBlock(D, base, useLatents, doNormalize)
    if nargin < 3
        useLatents = true;
    end
    if nargin < 4
        doNormalize = true;
    end
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    if useLatents
        decoderStr = 'fDecoder';
        spikeStr = 'latents';
    else
        decoderStr = 'nDecoder';
        spikeStr = 'spikes';
    end
    rowStr = 'RowM2';
    RB1 = B1.(decoderStr).(rowStr);
    RB2 = B2.(decoderStr).(rowStr);
    
    RB1 = RB1*RB1'*B1.(decoderStr).M2';
    RB2 = RB2*RB2'*B2.(decoderStr).M2';

    if any(base == '2')
        baseRB = RB2;
    else
        baseRB = RB1;
    end

    Z1 = B1.(spikeStr);
    Z2 = B2.(spikeStr);
    
    nrmf = @(z) doNormalize*norm(z) + (1-doNormalize)*1;

%     figure;
    set(gcf, 'color', 'w');
    hold on; axis off;
    title([D.datestr ' in Map ' base]);

    trgs = sort(unique(B2.targetAngle, 'rows'));
    xs = B2.trial_index;
    xsb = prctile(xs, [25 75]);
    
    gs1 = B1.thetaGrps;
    gs2 = B2.thetaGrps;
    grps = sort(unique(gs2));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));

    if doNormalize
        gain = 1;
    else
        gain = 0.5*norm(max(Z1)*baseRB);
    end
    plot(0, 0, 'sk'); plot(0, 0, '+k');
    
    % show targets
    for ii = 1:numel(grps)
        t = trgs(ii);% - 90;
        tx = cosd(t); ty = -sind(t);
        plot(gain*tx, gain*ty, 'x', 'MarkerSize', 20, 'Color', 'k');% clrs(ii,:));
        plot(gain*tx, gain*ty, 'ko', 'MarkerSize', 20, 'MarkerFaceColor', clrs(ii,:));
    end
    
    % show avg cursor movement
    for ii = 1:numel(grps)        

        ix = gs2 == grps(ii);
        ix1 = ix & (xs <= xsb(1));
        ix2 = ix & (xs >= xsb(1)) & (xs <= xsb(2));
        ix3 = ix & (xs >= xsb(2));

        ix = gs1 == grps(ii);
        z = mean(Z1(ix,:)); v0 = z*baseRB; vf = z*RB1;
        v0 = v0./nrmf(v0);
        vf = vf./nrmf(vf);

        z = mean(Z2(ix1,:)); v1 = z*baseRB;
        v1 = v1./nrmf(v1);
        plot(v1(1), v1(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));

        z = mean(Z2(ix2,:)); v2 = z*baseRB;
        v2 = v2./nrmf(v2);
        plot(v2(1), v2(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));

        z = mean(Z2(ix3,:)); v3 = z*baseRB;
        v3 = v3./nrmf(v3);
        plot(v3(1), v3(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));        

        vs = [v0; v1; v2; v3];
        plot(vs(:,1), vs(:,2), 'Color', clrs(ii,:), 'LineWidth', 3);
        plot(v0(1), v0(2), 's', 'Color', 'k', 'MarkerFaceColor', 'k');
%         plot(vf(1), vf(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
        
    end
end
    