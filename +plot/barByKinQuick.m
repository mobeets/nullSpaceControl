function barByKinQuick(D, Hs, nm, errBarNm)
    plot.barByKin([Hs.covError], {Hs.name}, ...
        nm, D.datestr, errBarNm, {Hs.([nm '_boots'])});
end
