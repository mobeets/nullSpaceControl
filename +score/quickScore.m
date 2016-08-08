function err = quickScore(Z, Zh, gs, fcn)
    if nargin < 4
        fcn = @nanmean;
    end
    grps = sort(unique(gs));
    err = nan(numel(grps),1);
    
    ix1 = ~any(isnan(Z),2);
    ix2 = ~any(isnan(Zh),2);
    for ii = 1:numel(grps)
        ix = gs == grps(ii);        
        err(ii) = norm(fcn(Z(ix&ix1,:)) - fcn(Zh(ix&ix2,:)));
    end
end
