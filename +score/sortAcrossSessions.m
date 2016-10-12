function scs = sortAcrossSessions(vs, dim)
    if nargin < 2
        dim = 1;
    end
    [~,vsind] = sort(vs, dim);
    [~,scs] = sort(vsind, dim);
end
