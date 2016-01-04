function v = errOfMeans(zMu, zhMu)

    errs = arrayfun(@(jj) norm(zMu{jj} - zhMu{jj}), 1:numel(zMu));
    v = mean(errs);

end
