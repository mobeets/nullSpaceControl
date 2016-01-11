function basis = getBasis(rowSpace)
% rowSpace is 10x2 containing 2 linearly independent vectors in R^10
% basis is 10x10, where columns contain orthonormal basis vectors
% basis(:,1:2) spans the same space as rowSpace
% basis(:,3:10) spans the space orthogonal to rowSpace (i.e. the null space)

rowBasis = orth(rowSpace);
nullBasis = null(rowSpace');

basis = [rowBasis, nullBasis];