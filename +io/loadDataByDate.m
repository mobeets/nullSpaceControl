function D = loadDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'preprocessed', [dtstr '.mat']);    
    if ~exist(fnm, 'file')
        warning(['Preprocessed data for ' dtstr ' does not exist. Loading raw.']);
        D = io.loadRawDataByDate(dtstr);
    else
        data = load(fnm);
        D = data.D;
    end
    
    D.params = io.setFilterDefaults(D.datestr);

end
