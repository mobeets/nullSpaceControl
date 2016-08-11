function [SMu, SCov, D, hypnms] = loadData(dirNm, dtEx)

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    Y = load(fnm);
    SMu = Y.SMu; SCov = Y.SCov; hypnms = Y.nms;
    [D, hypnms] = figs.exampleSession(dirNm, dtEx);

end
