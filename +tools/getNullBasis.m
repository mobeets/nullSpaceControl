function NM = getNullBasis(M)
    NM = null(M);
    assert(norm(NM'*NM - eye(size(NM,2))) < 1e-12);
end
