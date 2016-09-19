function [NB, RB] = getNulRowBasis(M)
    RB = orth(M');
    NB = null(M);

%     [u,s,v] = svd(M);
%     rnk = size(u,1);
%     NB = v(:,rnk+1:end); % null(M)
%     RB = v(:,1:rnk);
    
%     [~,~,bProj] = svd(NB);
%     NB = NB*bProj;
    
%     NM = null(M'*M);
%     NM = null(M);

    % if NB/RB have orthonormal columns, then B'*B = I
    assert(det([NB RB]) - 1 < 1e-10); % just for fun
    assert(norm(NB'*NB - eye(size(NB,2))) < 1e-12);
    assert(norm(RB'*RB - eye(size(RB,2))) < 1e-12);
end
