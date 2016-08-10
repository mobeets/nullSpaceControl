function D = makeImeDefault(D, useSpikes)
    if nargin < 2
        useSpikes = false;
    end

    D.blocks(1).thetas = D.blocks(1).thetasIme;
    D.blocks(2).thetas = D.blocks(2).thetasIme;
    D.blocks(1).thetaActuals = D.blocks(1).thetaActualsIme;
    D.blocks(2).thetaActuals = D.blocks(2).thetaActualsIme;
    
    % for minimum/baseline
    D.blocks(1).vel = D.blocks(1).velIme;
    D.blocks(1).velNext = D.blocks(1).velNextIme;
    D.blocks(2).vel = D.blocks(2).velIme;
    D.blocks(2).velNext = D.blocks(2).velNextIme;
    
    D.blocks(1).fDecoder = D.blocks(1).fImeDecoder;
    D.blocks(2).fDecoder = D.blocks(2).fImeDecoder;
    D.blocks(1).nDecoder = D.blocks(1).nImeDecoder;
    D.blocks(2).nDecoder = D.blocks(2).nImeDecoder;
    D.blocks(1).thetaGrps = D.blocks(1).thetaImeGrps;
    D.blocks(2).thetaGrps = D.blocks(2).thetaImeGrps;
    D.blocks(1).thetaActualGrps = D.blocks(1).thetaActualImeGrps;
    D.blocks(2).thetaActualGrps = D.blocks(2).thetaActualImeGrps;
    D.blocks(1).thetaActualGrps16 = D.blocks(1).thetaActualImeGrps16;
    D.blocks(2).thetaActualGrps16 = D.blocks(2).thetaActualImeGrps16;
    
    D.blocks(1) = rmThNans(D.blocks(1));
    D.blocks(2) = rmThNans(D.blocks(2));
    
    if useSpikes
        D.blocks(1).fDecoder = D.blocks(1).nImeDecoder;
        D.blocks(2).fDecoder = D.blocks(2).nImeDecoder;
        D.blocks(1).latents = D.blocks(1).spikes;
        D.blocks(2).latents = D.blocks(2).spikes;
    end
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
