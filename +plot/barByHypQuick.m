function barByHypQuick(Hs, nm)

    if isfield(Hs, [nm '_se'])
        errs = [Hs.([nm '_se'])];
    else
        errs = [];
    end
    plot.barByHyp([Hs.(nm)], {Hs.name}, nm, errs);

end
