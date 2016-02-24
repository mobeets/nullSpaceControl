function Z = regRowOnNulFit(D)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    
    gs = B1.thetaGrps;
    Y1 = B1.latents;
    YN = Y1*NB2;
    YR = Y1*RB2;
    
    % regress
    grps = sort(unique(gs));
    mdls = cell(numel(grps), size(YN,2));
    grps = sort(unique(gs));
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        for jj = 1:size(YN,2)
           y = YN(ix,jj);
           X = YR(ix,:);
           mdls{ii,jj} = fitlm(X, y);
        end
    end
    
    % predict
    Z2 = B2.latents;
    YR = Z2*RB2;
    Zn = nan(size(YR,1), size(YN,2));
    nt = size(Z2,1);
    for t = 1:nt
        thix = B2.thetaGrps(t) == grps;
        zr = YR(t,:);
        for jj = 1:size(YN,2)
            zn = mdls{thix,jj}.predict(zr);
            Zn(t,jj) = zn;
        end
    end
    Z = Z2*(RB2*RB2') + Zn*NB2';

end
