function D = loadDataByDate(datestr)

    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'preprocessed', [datestr '.mat']);    
    if ~exist(fnm, 'file')
        error(['Preprocessed data for ' datestr ' does not exist.']);
    end
    data = load(fnm);
    D = data.D;
    
    D.params = io.setFilterDefaults(D.params);

end
