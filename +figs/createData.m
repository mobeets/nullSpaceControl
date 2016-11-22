function createData(dirNm, dts)

    baseDir = fullfile('data', 'fits', dirNm);

    SMu = cell(numel(dts), 1);
    SCov = SMu;
    SMuErr = SMu;
    SCovErr = SMu;
    ntimes = nan(numel(dts),2);
    ntrials = nan(numel(dts),2);
    for ii = 1:numel(dts)
        dtstr = dts{ii}
        X = load(fullfile(baseDir, [dtstr '.mat'])); D = X.D;
        SMu{ii} = [D.score.errOfMeans];
        SCov{ii} = [D.score.covError];
        ngrps = numel([D.score.errOfMeansByKin]);
        muerrs = std(cell2mat({D.score(2:end).errOfMeansByKin}')');
        cverrs = std(cell2mat({D.score(2:end).covErrorByKin}));
        muerrs = [0 muerrs]; % for observed
        cverrs = [0 cverrs]; % for observed
        SMuErr{ii} = muerrs/sqrt(ngrps);
        SCovErr{ii} = cverrs/sqrt(ngrps);
        ntimes(ii,:) = [numel(D.blocks(1).time) numel(D.blocks(2).time)];
        ntrials(ii,:) = [numel(unique(D.blocks(1).trial_index)) ...
            numel(unique(D.blocks(2).trial_index))];
    end
    SMu = cell2mat(SMu);
    SMuErr = cell2mat(SMuErr);
    SCov = cell2mat(SCov);
    SCovErr = cell2mat(SCovErr);
    nms = {D.score.name};

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    save(fnm, 'SMu', 'SCov', 'SMuErr', 'SCovErr', 'nms', ...
        'ntimes', 'ntrials', 'dts');

end
