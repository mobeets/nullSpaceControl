function createData(dirNm, dts)

    baseDir = fullfile('data', 'fits', dirNm);

    SMu = cell(numel(dts), 1);
    SCov = SMu;
    ntrials = nan(numel(dts),2);
    for ii = 1:numel(dts)
        dtstr = dts{ii}
        X = load(fullfile(baseDir, [dtstr '.mat'])); D = X.D;
        SMu{ii} = [D.score.errOfMeans];
        SCov{ii} = [D.score.covError];
        ntrials(ii,:) = [numel(unique(D.blocks(1).trial_index)) ...
            numel(unique(D.blocks(2).trial_index))];
    end
    SMu = cell2mat(SMu);
    SCov = cell2mat(SCov);
    nms = {D.score.name};

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    save(fnm, 'SMu', 'SCov', 'nms', 'ntrials');

end
