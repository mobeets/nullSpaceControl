
dtstr = '20120601';
params = io.setUnfilteredDefaults();
opts = struct('doRotate', false);
D = io.quickLoadByDate(dtstr, params, opts);
