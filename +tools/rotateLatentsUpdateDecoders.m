function D = rotateLatentsUpdateDecoders(D, doStretch)
    if nargin < 2
        doStretch = false;
    end

    L = D.simpleData.nullDecoder.FactorAnalysisParams.L;

    [U,S,V] = svd(L, 'econ');
    if doStretch
        Lrot = U;
        spikeRot = V*S;
    else
        Lrot = U*S;
        spikeRot = V;
    end
    if det(spikeRot) < 0
        spikeRot(:,1) = -spikeRot(:,1);
    end
    
    % random unitary rotation
%     R = tools.randomUnitary(size(L,2));
%     Lrot = Lrot*R';
%     spikeRot = spikeRot*R';
    
    for ii = 1:numel(D.blocks) 
        Z = D.blocks(ii).latents;
        
        D.blocks(ii).fDecoder = updateDecoder(Z, D.blocks(ii).fDecoder, spikeRot);
        if isfield(D.blocks(ii), 'fImeDecoder') && ...
                isa(D.blocks(ii).fImeDecoder, 'struct')
            D.blocks(ii).fImeDecoder = updateDecoder(Z, ...
                D.blocks(ii).fImeDecoder, spikeRot);
        end
        D.blocks(ii).latents = Z*spikeRot;
        
    end
    D.simpleData.nullDecoder.FactorAnalysisParams.Lrot = Lrot;
    D.simpleData.nullDecoder.FactorAnalysisParams.spikeRot = spikeRot;
    
end

function dec = updateDecoder(Z, dec, spikeRot)
    M2 = dec.M2;
    R2 = dec.RowM2;

    Znew = Z*spikeRot; % L = USV', u = Lz
    M2new = M2*inv(spikeRot)';
    % n.b. will fail if nans in Znew or Z
    ixNotNan = ~any(isnan(Z),2);
    assert(norm(Znew(ixNotNan,:)*M2new' - Z(ixNotNan,:)*M2') < 1e-10, 'Activity not preserved');

    [NulM2, RowM2] = tools.getNulRowBasis(M2new); % neg 1st col
    a1 = Znew*RowM2(:,1);
    b1 = Z*R2(:,1);

    % bit of a hack to make sure columns have correct sign
    if norm(a1-b1) > 1e-10 && norm(a1+b1) < 1e-10
        RowM2(:,1) = -RowM2(:,1);
    end
    
    dec.M2 = M2new;
    dec.NulM2 = NulM2;
    dec.RowM2 = RowM2;

end


