function D = makeImeDefault(D)    

    D.blocks(1).thetas = D.blocks(1).thetasIme;
    D.blocks(2).thetas = D.blocks(2).thetasIme;
    D.blocks(1).thetaActuals = D.blocks(1).thetaActualsIme;
    D.blocks(2).thetaActuals = D.blocks(2).thetaActualsIme;
    D.blocks(1).fDecoder = D.blocks(1).fImeDecoder;
    D.blocks(2).fDecoder = D.blocks(2).fImeDecoder;
    D.blocks(1).thetaGrps = D.blocks(1).thetaImeGrps;
    D.blocks(2).thetaGrps = D.blocks(2).thetaImeGrps;
    D.blocks(1).thetaActualGrps = D.blocks(1).thetaActualImeGrps;
    D.blocks(2).thetaActualGrps = D.blocks(2).thetaActualImeGrps;
    D.blocks(1).thetaActualGrps16 = D.blocks(1).thetaActualImeGrps16;
    D.blocks(2).thetaActualGrps16 = D.blocks(2).thetaActualImeGrps16;
    
    D.blocks(1) = rmThNans(D.blocks(1));
    D.blocks(2) = rmThNans(D.blocks(2));
        
end

function B = rmThNans(B)
    fns = fieldnames(B);
    ix = ~isnan(B.thetas) & ~isnan(B.thetaActuals);
    for ii = 1:numel(fns)
        x = B.(fns{ii});
        if size(x,1) == numel(ix)
            B.(fns{ii}) = x(ix,:);
        end
    end

end
