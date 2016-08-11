function createData(dirNm, dts)

    baseDir = fullfile('data', 'fits', dirNm);

    SMu = cell(numel(dts), 1);
    SCov = SMu;
    for ii = 1:numel(dts)
        dtstr = dts{ii}
        X = load(fullfile(baseDir, [dtstr '.mat'])); D = X.D;
        SMu{ii} = [D.score.errOfMeans];
        SCov{ii} = [D.score.covError];
    end
    SMu = cell2mat(SMu);
    SCov = cell2mat(SCov);
    nms = {D.score.name};

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    save(fnm, 'SMu', 'SCov', 'nms');

end
