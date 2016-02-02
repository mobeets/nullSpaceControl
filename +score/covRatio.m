function v = covRatio(zCov, zhCov)

    errf = @(z, zh) (det(zh)/det(z))^(1/size(z,1));
    errs = arrayfun(@(jj) errf(zCov{jj}, zhCov{jj}), 1:numel(zCov))
    v = mean(errs);

end
