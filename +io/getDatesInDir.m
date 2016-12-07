function dts = getDatesInDir(baseDir)
    ds = dir(baseDir); ds = ds(~[ds.isdir]); ds = {ds.name};
    dts = cellfun(@(d) strrep(d, '.mat', ''), ds, 'uni', 0);
end
