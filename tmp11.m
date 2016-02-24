
B1 = D.blocks(1);
B2 = D.blocks(2);
NB2 = B2.fDecoder.NulM2;
gs = B2.thetaGrps;
grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));

for ii = 1:numel(grps)
    ix = gs == grps(ii);
    xs1 = B1.thetas + 180;
    xs2 = B1.thetas(ix) + 180;
    Y1 = B1.latents*NB2;
    Y2 = B2.latents(ix,:)*NB2;
    
    offs = 0:15:90;
    scs = nan(numel(offs),1);
    for jj = 1:numel(offs)
        
    end
    
end
