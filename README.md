
### Setup

```
setpref('factorSpace', 'data_directory', '/path/to/data');
DATADIR = getpref('factorSpace', 'data_directory');
```

Assumes the following files are in `fullfile(DATADIR, mnkNm, dtstr)`:

* `*simpleData_combined.mat`
* `kalmanInitParamsFA*(1).mat`

where `mknNm` is either "Jeffy" or "Lincoln", and dtstr is something like "20120601". (n.b. `*` indicates a wildcard.)

If an IME model has been fit, it should live in `fullfile(DATADIR, 'ime')` with a `.mat` file equal to the `dtstr`.
