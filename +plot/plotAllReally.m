
dtstr = '20120525';

%% fit

close all;
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

%% hyp fits over time -- IME

if exist(io.pathToIme(dtstr), 'file')
    close all;
    nms = {'kinematics mean', 'cloud-hab', 'habitual'};
    popts = struct('doSave', true, 'askedOnce', false, ...
        'plotdir', fullfile('plots', 'all', dtstr, 'hypsByTrials_ime'));
    hypopts = struct('decoderNm', 'fImeDecoder');
    plot.hypErrorsByTime(dtstr, nms, popts, hypopts, 'trial_length');
end

%% behavior over time -- IME

if exist(io.pathToIme(dtstr), 'file')
    close all;
    popts = struct('doSave', true, 'fignm', '-', ...
        'plotdir', fullfile('plots', 'all', dtstr, 'behavByTrials_ime'), ...
        'askedOnce', false);
    hopts = struct('decoderNm', 'fImeDecoder');
    plot.behaviorGrid(dtstr, [], popts, hopts);
end

%% CCA over time -- IME

if exist(io.pathToIme(dtstr), 'file')
    close all;
    popts = struct('doSave', true, 'fignm', '-CCA', ...
        'plotdir', fullfile('plots', 'all', dtstr, 'actByTrials_ime'), ...
        'askedOnce', false);
    hopts = struct('decoderNm', 'fImeDecoder');
    plot.activityGrid(dtstr, [], popts, hopts);
end
