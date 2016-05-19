function barByHypQuick(D, Hs, nm, errBarNm)
    if nargin < 4
        errBarNm = '';
    end
    if isfield(Hs, [nm '_boots'])
        fldnm = [nm '_boots'];
    else
        fldnm = nm;
    end
    plot.barByHyp([Hs.(nm)], {Hs.name}, ...
        nm, D.datestr, errBarNm, {Hs.(fldnm)});
end
