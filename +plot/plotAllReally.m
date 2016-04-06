
dtstr = '20120525';
% dtstr = '20120601';
dtstr = '20131205';
doSave = false;

%% fit

doSolos = true;
nms = {'kinematics mean', 'habitual', 'cloud-hab', 'condnrm', ...
    'volitional', 'baseline', 'minimum', 'unconstrained'};
% nms = {'kinematics mean', 'habitual', 'cloud-hab', 'condnrmkin', ...
%     'volitional', 'unconstrained'};
popts = struct('doSave', doSave, 'doSolos', doSolos, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypScores'), ...
    'doTimestampFolder', false);
% hypopts = struct('doSample', false);
hypopts = struct();
D = fitByDate(dtstr, [], nms, popts, [], hypopts);

%% hyp fits over time

close all;
nms = {'kinematics mean', 'cloud-hab', 'habitual', 'cloud-raw'};
popts = struct('doSave', doSave, 'askedOnce', false, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypsByTrials'));
hypopts = struct('decoderNm', 'fDecoder');
plot.hypErrorsByTime(dtstr, nms, popts, hypopts, 'trial_length');

%% behavior over time

close all;
popts = struct('doSave', doSave, 'fignm', '-', ...
    'plotdir', fullfile('plots', 'all', dtstr, 'behavByTrials'), ...
    'askedOnce', false);
plot.behaviorGrid(dtstr, [], popts);

%% CCA over time

close all;
popts = struct('doSave', doSave, 'fignm', '-CCA', ...
    'plotdir', fullfile('plots', 'all', dtstr, 'actByTrials'), ...
    'askedOnce', false);
plot.activityGrid(dtstr, [], popts);

%% fit -- IME

close all;
nms = {'kinematics mean', 'habitual', 'cloud-hab', 'volitional', ...
    'baseline', 'minimum', 'unconstrained'};
popts = struct('doSave', doSave, 'doSolos', true, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypScores_ime'), ...
    'doTimestampFolder', false);
hypopts = struct('decoderNm', 'fImeDecoder');
fitByDate(dtstr, [], nms, popts, [], hypopts);

%% hyp fits over time -- IME

if exist(io.pathToIme(dtstr), 'file')
    close all;
    nms = {'kinematics mean', 'cloud-hab', 'habitual'};
    popts = struct('doSave', doSave, 'askedOnce', false, ...
        'plotdir', fullfile('plots', 'all', dtstr, 'hypsByTrials_ime'));
    hypopts = struct('decoderNm', 'fImeDecoder');
    plot.hypErrorsByTime(dtstr, nms, popts, hypopts, 'trial_length');
end

%% CCA over time -- IME

if exist(io.pathToIme(dtstr), 'file')
    close all;
    popts = struct('doSave', doSave, 'fignm', '-CCA_ime', ...
        'plotdir', fullfile('plots', 'all', dtstr, 'actByTrials_ime'), ...
        'askedOnce', false);
    hopts = struct('decoderNm', 'fImeDecoder');
    plot.activityGrid(dtstr, [], popts, hopts);
end

%%

disp('done');
