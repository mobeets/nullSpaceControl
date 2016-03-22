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
        M2 = D.blocks(ii).fDecoder.M2;
        N2 = D.blocks(ii).fDecoder.NulM2;
        R2 = D.blocks(ii).fDecoder.RowM2;        

        Znew = Z*spikeRot; % L = USV', u = Lz
        M2new = M2*inv(spikeRot)';
        % n.b. will fail if nans in Znew or Z
        ixNotNan = ~any(isnan(Z),2);
        assert(norm(Znew(ixNotNan,:)*M2new' - Z(ixNotNan,:)*M2') < 1e-10, 'Activity not preserved');
                
        [NulM2, RowM2] = tools.getNulRowBasis(M2new); % neg 1st col
        
        a1 = Znew*RowM2(:,1); a2 = Znew*RowM2(:,2);
        b1 = Z*R2(:,1); b2 = Z*R2(:,2);
%         [norm(a1-b1) norm(a2-b2) norm(a1-b2) norm(a2-b1) ...
%             norm(a1+b1) norm(a2+b2) norm(a1+b2) norm(a2+b1)]

        % bit of a hack to make sure columns have correct sign
        if norm(a1-b1) > 1e-10 && norm(a1+b1) < 1e-10
            RowM2(:,1) = -RowM2(:,1);
        end

%         assert(norm(Znew*RowM2 - Z*R2) < 1e-10, ...
%             ['Row activity not preserved, err = ' ...
%             num2str(norm(Znew*RowM2 - Z*R2))]);
%         assert(norm(Znew*NulM2 - Z*N2) < 1e-10, ...
%             ['Nul activity not preserved, err = ' ...
%             num2str(norm(Znew*NulM2 - Z*N2))]);

        D.blocks(ii).latents = Znew;
        D.blocks(ii).fDecoder.M2 = M2new;
        D.blocks(ii).fDecoder.NulM2 = NulM2;
        D.blocks(ii).fDecoder.RowM2 = RowM2;
    end
    D.simpleData.nullDecoder.FactorAnalysisParams.Lrot = Lrot;
    D.simpleData.nullDecoder.FactorAnalysisParams.spikeRot = spikeRot;
    
end
