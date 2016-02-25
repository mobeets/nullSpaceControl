function D = loadDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'preprocessed', [dtstr '.mat']);    
    if ~exist(fnm, 'file')
        error(['Preprocessed data for ' dtstr ' does not exist.']);
    end
    data = load(fnm);
    D = data.D;
    
    D.params = io.setFilterDefaults(D.params);
%     D.trials.thetas = mod(D.trials.thetas, 360);
%     D.trials.thetaGrps = score.thetaGroup(D.trials.thetas, ...
%         score.thetaCenters(8));

end
