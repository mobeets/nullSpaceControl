
B1 = D.blocks(1);
B2 = D.blocks(2);
NB2 = B2.fDecoder.NulM2;
RB2 = B2.fDecoder.RowM2;

Z1 = B1.latents;
Z2 = B2.latents;

figure; set(gcf, 'color', 'w');
hold on; axis off;

trgs = unique(B.targetAngle, 'rows');
xs = B.trial_index;
xsb = prctile(xs, [25 75]);
grps = sort(unique(B.thetaGrps));
clrs = cbrewer('div', 'RdYlGn', numel(grps));

for ii = 1:numel(grps)    
        
    ix = B2.thetaGrps == grps(ii);
    ix1 = ix & (xs <= xsb(1));
    ix2 = ix & (xs >= xsb(1)) & (xs <= xsb(2));
    ix3 = ix & (xs >= xsb(2));
    
    ix = B1.thetaGrps == grps(ii);
    z = mean(Z1(ix,:)); v0 = z*RB2;    
    
    z = mean(Z2(ix1,:)); v1 = z*RB2;
    plot(v1(1), v1(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    
    z = mean(Z2(ix2,:)); v2 = z*RB2;
    plot(v2(1), v2(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    
    z = mean(Z2(ix3,:)); v3 = z*RB2;
    plot(v3(1), v3(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    
    z = mean(Z1(ix,:)); vf = z*RB1; nrm = norm(vf); %vf = vf./nrm;
    plot(vf(1), vf(2), 'o', 'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    
    vs = [v0; v1; v2; v3];
    plot(vs(:,1), vs(:,2), 'Color', clrs(ii,:), 'LineWidth', 3);
    plot(v0(1), v0(2), 's', 'Color', 'k', 'MarkerFaceColor', 'k');
    
    t = trgs(ii) - 90;
    tx = cosd(t); ty = sind(t);
    plot(2*tx, 2*ty, '+', 'Color', clrs(ii,:));
end
