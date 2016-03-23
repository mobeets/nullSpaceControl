function D = loadRawDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    
    dr1 = fullfile(DATADIR, 'Jeffy', dtstr);
    dr2 = fullfile(DATADIR, 'Lincoln', dtstr);
    fs1 = dir(dr1);
    fs1 = {fs1(~[fs1.isdir]).name};
    fs2 = dir(dr2);
    fs2 = {fs2(~[fs2.isdir]).name};
    if numel(fs1) + numel(fs2) == 0
        error('Date not found.');
        return;
    end
    if numel(fs1) > 0
        dr = dr1; fs = fs1;
    else
        dr = dr2; fs = fs2;
    end
    load(fullfile(dr, fs{1}));
    load(fullfile(dr, fs{2}));

    D.datestr = dtstr;
    D.kalmanInitParams = kalmanInitParams;
    D.simpleData = simpleData;
%     D.params = io.setBlockStartTrials(D.datestr);
    D.params.IDEAL_SPEED = 175;
    D.trials = io.makeTrials(D);
    
end
