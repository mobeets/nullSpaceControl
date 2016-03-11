
dts = {'20120525', '20120601', '20120709', '20131212'};
params = struct('MAX_ANGULAR_ERROR', 360);

for ii = 1:numel(dts)
    close all;
    dtstr = dts{ii};
    D = io.quickLoadByDate(dtstr, params);
    ps0 = struct('START_SHUFFLE', nan, ...
        'END_SHUFFLE', D.params.START_SHUFFLE, 'MAX_ANGULAR_ERROR', 360);
    D = fitByDate(dtstr, [true false true], ps0);
end

