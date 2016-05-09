function barByHypQuick(D, Hs, nm, errBarNm)
    if nargin < 4
        errBarNm = '';
    end
    plot.barByHyp([Hs.(nm)], {Hs.name}, ...
        nm, D.datestr, errBarNm, {Hs.([nm '_boots'])});
end
