function fnm = pathToIme(dtstr)
    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'ime', [dtstr '.mat']);
end
