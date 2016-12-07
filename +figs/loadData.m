function [SMu, SCov, HistErr, D, hypnms, ntrials, ntimes, SMuErr, ...
    SCovErr, dts] = loadData(dirNm, dtEx, dts)

    fnm = fullfile('data', 'fits', [dirNm '.mat']);
    Y = load(fnm);
    if isfield(Y, 'dts')
        dtsa = Y.dts;
    else
        dtsa = dts;
    end
    SMu = Y.SMu; SCov = Y.SCov; hypnms = Y.nms;   

    if isfield(Y, 'ntrials')
        ntrials = Y.ntrials;
    else
        ntrials = [];
    end
    if isfield(Y, 'ntimes')
        ntimes = Y.ntimes;
    else
        ntimes = [];
    end
    if isfield(Y, 'HistErr')
        HistErr = Y.HistErr;
    else
        HistErr = nan(size(SMu));
    end
    if isfield(Y, 'SMuErr')
        SMuErr = Y.SMuErr;
        SCovErr = Y.SCovErr;
    else
        SMuErr = [];
        SCovErr = [];
    end
    [D, hypnms] = figs.exampleSession(dirNm, dtEx);

    % filter out SMu and SCov by dts
    ix = ismember(dtsa, dts);
    if numel(ix) ~= size(SMu,1)
        dtsa = io.getDatesInDir(fullfile('data', 'fits', dirNm));
        ix = ismember(dtsa, dts);
        if numel(ix) ~= size(SMu,1)
            warning('No way of knowing what dates these are since they were not saved.');
            return;
        else
            warning('Guessing dates from files in data directory');
        end
    end
    SMu = SMu(ix,:);
    SCov = SCov(ix,:);
    HistErr = HistErr(ix,:);
    ntrials = ntrials(ix,:);
    if ~isempty(ntimes)
        ntimes = ntimes(ix,:);
    end
    dts = dtsa(ix);

end
