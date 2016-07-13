function err = quickScore(Z, Zh, gs)
    grps = sort(unique(gs));
    err = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        err(ii) = norm(nanmean(Z(ix,:)) - nanmean(Zh(ix,:)));
    end
end
