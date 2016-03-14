function rotThetas = findReaimingAnglesWithIntuitive(D)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    RB1 = B1.fDecoder.RowM2;
    RB2 = B2.fDecoder.RowM2;
%     RB1 = B1.fDecoder.M2';
%     RB2 = B2.fDecoder.M2';

    Z1 = B1.latents;
    
    gs = B1.thetaGrps;
    grps = sort(unique(gs));
    rotThetas = nan(size(grps));
    for ii = 1:numel(grps)
        ix = gs == grps(ii) & abs(B1.angError) < 20;
        z = mean(Z1(ix,:));
        r1 = z*RB1;
        r2 = z*RB2;
        rotThetas(ii) = tools.computeAngle(r2, r1);
    end

end
