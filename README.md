
### Setup

```
setpref('factorSpace', 'data_directory', '/path/to/data');
DATADIR = getpref('factorSpace', 'data_directory');
```
Data session files are structured as follows (n.b. `*` is a wildcard operator):

```
/DATADIR
   /Jeffy
      /20120302
          *simpleData_combined.mat
          kalmanInitParamsFA*.mat
      /20120303
      ...
   /Lincoln
   /Nelson
   ...
```

To process a list of session files for some dates, e.g., `dts = {'20160101', '20160102'}`, run the following:

1. __Preprocess__: `cellfun(@io.saveDataByData, dts);`
2. __Fit behavioral asymptotes__: Edit and run `behav.asymptotesAll`, making sure to add to the existing file `'data/asymptotes/bySession.mat'`.
3. __Fit IME__: Run `imefit.fitAll` for your `dts` after setting `doSave` true, `fitPostLearnOnly` true, and `doCv` false. For each `dtstr`, you should verify there is now a file in `fullfile(DATADIR, 'ime', [dtstr .mat])`
