function D = rotateLatentsUpdateDecoders(D)

    L = D.simpleData.nullDecoder.FactorAnalysisParams.L;
    [U,S,V] = svd(L, 'econ');
    D.simpleData.nullDecoder.FactorAnalysisParams.Lrot = U;
    
    for ii = 1:numel(D.blocks) 
        Z = D.blocks(ii).latents;
        M2 = D.blocks(ii).fDecoder.M2;

        Znew = Z*V*S;
        M2new = M2*V*diag(1./diag(S));
        
        assert(norm(Znew*M2new' - Z*M2') < 1e-10);
        
        [NulM2, RowM2] = tools.getNulRowBasis(M2new);
        D.blocks(ii).latents = Znew;
        D.blocks(ii).fDecoder.M2 = M2new;
        D.blocks(ii).fDecoder.NulM2 = NulM2;
        D.blocks(ii).fDecoder.RowM2 = RowM2;
    end
    
end
