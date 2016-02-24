function ds = featureDist(x, xs, fld, distFcn)
% finds distance between a field of x and every element in xs

    if nargin < 4
        distFcn = @(A, dim) sqrt(sum(A.^2, dim)); % norm
    end

    v = x.(fld);
    if numel(v) == 1
        ds = distFcn([xs.(fld)] - v, 1)';
    else
        vs = cell2mat({xs.(fld)}');
        ds = distFcn(bsxfun(@minus, vs, v), 2);
    end

end
