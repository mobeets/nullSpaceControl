function [SMu, SCov, D, hypnms, ntrials] = loadData(dirNm, dtEx)

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    Y = load(fnm);
    SMu = Y.SMu; SCov = Y.SCov; hypnms = Y.nms; ntrials = Y.ntrials;
    [D, hypnms] = figs.exampleSession(dirNm, dtEx);

end
