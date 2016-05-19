
% dtstr = '20120525';
dtstr = '20131125';
% dtstr = '20120601';
% dtstr = '20131205';
doSave = true;
% nms = {'true', 'zero', 'habitual', 'cloud-hab', 'volitional'};
nms = {'true', 'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
        'unconstrained', 'minimum', 'baseline', 'volitional'};
% nms = {'true', 'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline', 'volitional', ...
%         'condnrm', 'condnrmkin', 'mean shift'};
smallNms = {'true', 'cloud-hab', 'habitual'};

%% fit

doSolos = true;
popts = struct('doSave', doSave, 'doSolos', doSolos, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypScores'), ...
    'doTimestampFolder', false);
hypopts = struct();
D = fitByDate(dtstr, [], nms, popts, [], hypopts);

%% marginal histograms

Hs = D.hyps(2:end);
grps = Hs(1).marginalHistograms_grps;
Zs = {Hs.marginalHistograms}';
Xs = Hs(1).marginalHistograms_Xs;

grps(~(grps == 0)) = nan; % only show grps == 0
plot.marginalDists(Zs, Xs, grps);

%% hyp fits over time

close all;
popts = struct('doSave', doSave, 'askedOnce', false, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypsByTrials'));
hypopts = struct('decoderNm', 'fDecoder');
plot.hypErrorsByTime(dtstr, smallNms, popts, hypopts, 'trial_length');

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
popts = struct('doSave', doSave, 'doSolos', true, ...
    'plotdir', fullfile('plots', 'all', dtstr, 'hypScores_ime'), ...
    'doTimestampFolder', false);
hypopts = struct('decoderNm', 'fImeDecoder');
fitByDate(dtstr, [], nms, popts, [], hypopts);

%% hyp fits over time -- IME

if exist(io.pathToIme(dtstr), 'file')
    close all;
    popts = struct('doSave', doSave, 'askedOnce', false, ...
        'plotdir', fullfile('plots', 'all', dtstr, 'hypsByTrials_ime'));
    hypopts = struct('decoderNm', 'fImeDecoder');
    plot.hypErrorsByTime(dtstr, smallNms, popts, hypopts, 'trial_length');
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
