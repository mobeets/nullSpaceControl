function errs = histError(Y, Yh)
    % calculate histogram error
    lfcn = @(y,yh) mean((y-yh).^2);
    ngrps = numel(Y);
    ncols = size(Y{1},2);
    errs = nan(ngrps, ncols);
    for ii = 1:ngrps
        for jj = 1:ncols
            errs(ii,jj) = lfcn(Y{ii}(:,jj), Yh{ii}(:,jj));
        end
    end
end
