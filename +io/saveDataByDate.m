function D = saveDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');

    D = io.loadRawDataByDate(dtstr);    
    timestamp = datetime();
    fullfile(DATADIR, 'preprocessed', dtstr)
    save(fullfile(DATADIR, 'preprocessed', dtstr), 'D', 'timestamp');

end
