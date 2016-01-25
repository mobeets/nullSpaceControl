function [NM, RM] = getNulRowBasis(M)
    [u,s,v] = svd(M);
    rnk = size(u,1);
    NM = v(:,rnk+1:end); % null(M)
    RM = v(:,1:rnk);
    
%     [~,~,bProj] = svd(NB);
%     NB = NB*bProj;
    
%     NM = null(M'*M);
%     NM = null(M);
    % if NM has orthonormal columns, then NM'*NM = I
    assert(norm(NM'*NM - eye(size(NM,2))) < 1e-12);
end
