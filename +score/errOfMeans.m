function [v, errs, pct_errs] = errOfMeans(zMu, zhMu)

    errs = arrayfun(@(jj) norm(zMu{jj} - zhMu{jj}), 1:numel(zMu));
    base = arrayfun(@(jj) norm(zMu{jj}), 1:numel(zMu));
    pct_errs = errs./base;
    v = mean(errs);

end
