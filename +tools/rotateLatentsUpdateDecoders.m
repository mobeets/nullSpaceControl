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
    
    % random unitary rotation
%     R = tools.randomUnitary(size(L,2));
%     Lrot = Lrot*R';
%     spikeRot = spikeRot*R';
    
    for ii = 1:numel(D.blocks) 
        Z = D.blocks(ii).latents;
        M2 = D.blocks(ii).fDecoder.M2;

        Znew = Z*spikeRot; % L = USV', u = Lz
        M2new = M2*inv(spikeRot)';
        assert(norm(Znew*M2new' - Z*M2') < 1e-10);
        
        [NulM2, RowM2] = tools.getNulRowBasis(M2new);
        D.blocks(ii).latents = Znew;
        D.blocks(ii).fDecoder.M2 = M2new;
        D.blocks(ii).fDecoder.NulM2 = NulM2;
        D.blocks(ii).fDecoder.RowM2 = RowM2;
    end
    D.simpleData.nullDecoder.FactorAnalysisParams.Lrot = Lrot;
    D.simpleData.nullDecoder.FactorAnalysisParams.spikeRot = spikeRot;
    
end
