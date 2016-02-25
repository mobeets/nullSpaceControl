function cursorMovementByBlock(D, base)
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;

    if any(base == '2')
        baseRB = RB2;
    else
        baseRB = RB1;
    end

    Z1 = B1.latents;
    Z2 = B2.latents;

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

    plot(0, 0, 'sk'); plot(0, 0, '+k');
    for ii = 1:numel(grps)    

        ix = gs2 == grps(ii);
        ix1 = ix & (xs <= xsb(1));
        ix2 = ix & (xs >= xsb(1)) & (xs <= xsb(2));
        ix3 = ix & (xs >= xsb(2));

        ix = gs1 == grps(ii);
        z = mean(Z1(ix,:)); v0 = z*baseRB; vf = z*RB1;

        z = mean(Z2(ix1,:)); v1 = z*baseRB;
        plot(v1(1), v1(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));

        z = mean(Z2(ix2,:)); v2 = z*baseRB;
        plot(v2(1), v2(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));

        z = mean(Z2(ix3,:)); v3 = z*baseRB;
        plot(v3(1), v3(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));        

        vs = [v0; v1; v2; v3];
        plot(vs(:,1), vs(:,2), 'Color', clrs(ii,:), 'LineWidth', 3);
        plot(v0(1), v0(2), 's', 'Color', 'k', 'MarkerFaceColor', 'k');
%         plot(vf(1), vf(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));

        t = trgs(ii);% - 90;
        tx = cosd(t); ty = sind(t);
        plot(2*tx, 2*ty, 'x', 'Color', 'k');% clrs(ii,:));
        plot(2*tx, 2*ty, 'o', 'Color', clrs(ii,:));
    end
end
    