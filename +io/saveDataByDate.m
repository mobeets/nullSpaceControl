function D = saveDataByDate(dtstr)
% BATCH MODE: cellfun(@io.saveDataByDate, dts);

    DATADIR = getpref('factorSpace', 'data_directory');

    D = io.loadRawDataByDate(dtstr);
    timestamp = datetime();
    fullfile(DATADIR, 'preprocessed', dtstr)
    save(fullfile(DATADIR, 'preprocessed', dtstr), 'D', 'timestamp');

end
