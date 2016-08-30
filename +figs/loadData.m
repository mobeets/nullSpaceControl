function [SMu, SCov, D, hypnms, ntrials, SMuErr, SCovErr] = ...
    loadData(dirNm, dtEx)

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    Y = load(fnm);
    SMu = Y.SMu; SCov = Y.SCov; hypnms = Y.nms;
    if isfield(Y, 'ntrials')
        ntrials = Y.ntrials;
    else
        ntrials = [];
    end
    if isfield(Y, 'SMuErr')
        SMuErr = Y.SMuErr;
        SCovErr = Y.SCovErr;
    else
        SMuErr = [];
        SCovErr = [];
    end
    [D, hypnms] = figs.exampleSession(dirNm, dtEx);

end
