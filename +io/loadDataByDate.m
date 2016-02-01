function D = loadDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'preprocessed', [dtstr '.mat']);    
    if ~exist(fnm, 'file')
        error(['Preprocessed data for ' dtstr ' does not exist.']);
    end
    data = load(fnm);
    D = data.D;
    
    D.params = io.setFilterDefaults(D.params);
    D.trials.thetaGrps = score.thetaGroup(D.trials.thetas + 180, ...
        score.thetaCenters(8));

end
