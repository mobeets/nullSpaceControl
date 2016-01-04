function v = covRatio(zMu, zhMu)

    errf = @(z, zh) (det(z)/det(zh))^(1/size(z,1));
    errs = arrayfun(@(jj) errf(zMu{jj}, zhMu{jj}), 1:numel(zMu));
    v = mean(errs);

end
