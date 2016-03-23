addpath(genpath(pwd))

%% Some example control session data from Steve's 2012 J. Neurosci paper
load('example_data.mat');

% U: cell array containing raw spike counts from each trial
% Y: cell array containing cursor positions from each trial
% Xtarget: cell array containing the target position from each trial

%%

cd /Users/mobeets/code/nullSpaceControl
% dtstr = '20120601';
dtstr = '20120525';
params = io.setUnfilteredDefaults();
params = io.updateParams(params, io.setBlockStartTrials(dtstr), true);

opts = struct('doRotate', false);
D = io.quickLoadByDate(dtstr, params, opts);
cd /Users/mobeets/code/nullSpaceControl/velime_codepack_v1.0/

%%

bind = 2;
[U, Y, Xtarget] = prep(D.blocks(bind));

%%

ime = D.ime;
outdir = '/Users/mobeets/code/nullSpaceControl/data/ime';
fnm = fullfile(outdir, [D.datestr '.mat']);
if exist(fnm, 'file')
    error('Not saving...file already exists.');
end
save(fnm, 'ime');

%% Fit velocity-IME model
init_method = 'current_regression';
verbose = true;
PARALLEL = false;
max_iters = 200; % I recommend 5,000 iterations for all real applications.
TAU = 3;
T_START = TAU + 2; % "whiskers" from each trial are well-defined beginning at timestep T_START
TARGET_RADIUS = 0.016;
TARGET_RADIUS = 20 + 18; % from Sadtler paper; positions in mm

[estParams,LL] = velime_fit(U,Y,Xtarget,TAU,...
    'INIT_METHOD',init_method,...
    'verbose',verbose,...
    'max_iters',max_iters);
D.ime(bind) = estParams;

%% Extract prior latent variable distributions ("whiskers")

% dec = D.blocks(bind).nDecoder;
% estParams.A = dec.M1;
% estParams.B = dec.M2*0.045;
% estParams.b0 = dec.M0*0.045;
% estParamsCopy2 = estParams;
% estParams = estParamsCopy2;
[E_P, E_V] = velime_extract_prior_whiskers(U, Y, Xtarget, estParams);

%% Compute angular errors from prior expectations over latent variables
result = velime_evaluate(U, Y, Xtarget, estParams, 'TARGET_RADIUS', TARGET_RADIUS, 'T_START', T_START);

%% Compare to cursor error

errs = cell(1,numel(U));
for ii = 1:numel(U)
    P_t = Y{ii};
    P_tp1 = P_t(:,T_START+1:end);
    P_t = P_t(:,T_START:end-1);
    errs{ii} = angular_error_from_perimeter(P_t, P_tp1, Xtarget{ii}, TARGET_RADIUS);
end

figure; set(gcf, 'color', 'w'); hold on; set(gca, 'FontSize', 14);
cursorErrs = abs(cell2mat(errs));
mdlErrs = abs(cell2mat(result.trial_error_angles_from_perimeter));
plot(mdlErrs, cursorErrs, '.');
xlabel('internal model errors (degrees)');
ylabel('cursor errors (degrees)');
title([D.datestr ' Blk' num2str(bind)]);

figure; set(gcf, 'color', 'w'); hold on; set(gca, 'FontSize', 14);
xs = 1:60;%round(max(mdlErrs));
ys = 1:60;%round(max(cursorErrs));
ns = hist3([mdlErrs; cursorErrs]', {xs, ys});
imagesc(xs, ys, log(ns)');
xlabel('internal model errors (degrees)');
ylabel('cursor errors (degrees)');
axis image;
title([D.datestr ' Blk' num2str(bind)]);

[mean(cursorErrs) mean(mdlErrs)]

%% Generate whisker plot
trialNo = 200;
figure; hold on;
fill_circle(Xtarget{trialNo},TARGET_RADIUS,'g');
plot(Y{trialNo}(1,:),Y{trialNo}(2,:),'k-o');
T = size(Y{trialNo},2);
for t = T_START:T
    plot(E_P{trialNo}(1:2:end,t),E_P{trialNo}(2:2:end,t),'r.-');
end
axis image