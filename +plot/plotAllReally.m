
dtstr = '20120601';

%% fit
nms = {'cloud-hab'};
popts = struct('doSave', true, 'doSolos', true, ...
    'plotdir', fullfile('plots', 'all', dtstr), 'doTimestampFolder', false);
D = fitByDate(dtstr, [], nms, popts, [], []);

%% hyp fits over time

close all;
nms = {'kinematics mean', 'cloud-hab', 'habitual'};
popts = struct('doSave', true, 'askedOnce', false, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypsByTrials'));
hypopts = struct('decoderNm', 'fDecoder');
plot.hypErrorsByTime(dtstr, nms, popts, hypopts, 'trial_length');

%% behavior over time

close all;
popts = struct('doSave', true, 'fignm', '-', ...
    'plotdir', fullfile('plots', 'all', dtstr, 'behavByTrials'), ...
    'askedOnce', false);
plot.behaviorGrid(dtstr, [], popts);

%% CCA over time

close all;
popts = struct('doSave', true, 'fignm', '-CCA', ...
    'plotdir', fullfile('plots', 'all', dtstr, 'actByTrials'), ...
    'askedOnce', false);
plot.activityGrid(dtstr, [], popts);
