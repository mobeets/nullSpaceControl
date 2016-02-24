function Z = kNNFit(D, K, fldnms)

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    C1 = struct2structArray(B1);
    C2 = struct2structArray(B2);
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    
    Z1 = B1.latents;
    Z2 = B2.latents;
    R1 = Z1*RB2;
    R2 = Z2*RB2;

    % add null space activity

    for ii = 1:numel(fldnms)
        fldnm = fldnms{ii};        
        vs1 = cell2mat({C1.(fldnm)}');
        vs2 = cell2mat({C2.(fldnm)}');
        if strcmpi(fldnm, 'vec2target')
            dststr = 'cosine';
        else
            dststr = 'euclidean';
        end
        [idx, dd] = knnsearch(vs1, vs2, 'k', K, 'distance', dststr);
        wts = bsxfun(@rdivide, 1./dd.^2, sum(1./dd.^2,2));
    end
    
    [nt, nn] = size(Z2);
    Zn = nan(nt,nn);
    for t = 1:nt
        ds = getDistances(R1, R2(t,:));
        
        ws = wts(t,:);
        ws(ds(idx(t,:)) >= 0.4) = nan;
        ws = ws./nansum(ws);
        ws(isnan(ws)) = 0;
        
        % could also weight by dd, or sample from idx(t,:)
        zs = Z1(idx(t,:),:);
%         Zn(t,:) = mean(zs);
%         Zn(t,:) = wts(t,:)*zs;
        Zn(t,:) = ws*zs;

%         zfa = Z1(ds <= d_min, :);
%         ind = randi(size(zfa,1),1);
%         zf = zfa(ind,:);

    end
    Z = Z2*(RB2*RB2') + Zn*(NB2*NB2');
    
%     nt = numel(C2);
%     for ii = 1:nt
%         C = C2(ii);
%         ds = featureDist(C, C1, fldnm);    
%     end

end

function ds = getDistances(Z, z)
    ds = bsxfun(@minus, Z, z);
    ds = sqrt(sum(ds.^2,2));
end
