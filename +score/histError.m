function errs = histError(Y, Yh, lfcn)
    % calculate histogram error
    if nargin < 3
%         lfcn = @(y,yh) mean((y-yh).^2);
        lfcn = @(y,yh) sum(abs(y-yh))/2;
    end
    ngrps = numel(Y);
    ncols = size(Y{1},2);
    errs = nan(ngrps, ncols);
    for ii = 1:ngrps
        for jj = 1:ncols
            Yc = Y{ii}(:,jj);
            Yhc = Yh{ii}(:,jj);
            Yc = Yc/sum(Yc);
            Yhc = Yhc/sum(Yhc);
%             assert(abs(sum(Yhc) - 1) < 1e-5, ...
%                 ['Not a pdf: sum = ' num2str(sum(Yhc))]);
            errs(ii,jj) = lfcn(Yc, Yhc);
        end
    end
end
