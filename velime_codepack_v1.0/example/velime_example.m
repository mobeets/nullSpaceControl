addpath(genpath(pwd))

%% Some example control session data from Steve's 2012 J. Neurosci paper
load('example_data.mat');

% U: cell array containing raw spike counts from each trial
% Y: cell array containing cursor positions from each trial
% Xtarget: cell array containing the target position from each trial

%%

cd /Users/mobeets/code/nullSpaceControl
dtstr = '20120601';
[U, Y, Xtarget] = prep(dtstr);
cd /Users/mobeets/code/nullSpaceControl/velime_codepack_v1.0/

% 
% Q1: removed the first 7 time-points per trial?
% Q2: how to compare to true decoder?
% Q3: simplest way to predict next cursor location under IME
% Q4: remove incorrects?
% Q5: spikes should have influence current cursor position?
%
% Notes:
% - movement onset as first point where computed cursor velocity exceeds
%       15% of baseline
% - angular error includes the target radius
%       (sum of cursor and target radii)
% 

%% Fit velocity-IME model
init_method = 'current_regression';
verbose = true;
PARALLEL = false;
max_iters = 500; % I recommend 5,000 iterations for all real applications.
TAU = 3;
T_START = TAU + 2; % "whiskers" from each trial are well-defined beginning at timestep T_START
TARGET_RADIUS = 0.016;
TARGET_RADIUS = 20 + 18; % from Sadtler paper; positions in mm

[estParams,LL] = velime_fit(U,Y,Xtarget,TAU,...
    'INIT_METHOD',init_method,...
    'verbose',verbose,...
    'max_iters',max_iters);

%% Extract prior latent variable distributions ("whiskers")
[E_P, E_V] = velime_extract_prior_whiskers(U, Y, Xtarget, estParams);

%% Compute angular errors from prior expectations over latent variables
result = velime_evaluate(U, Y, Xtarget, estParams, 'TARGET_RADIUS', TARGET_RADIUS, 'T_START', T_START);

%% Generate whisker plot
trialNo = 798;
figure; hold on;
fill_circle(Xtarget{trialNo},TARGET_RADIUS,'g');
plot(Y{trialNo}(1,:),Y{trialNo}(2,:),'k-o');
T = size(Y{trialNo},2);
for t = T_START:T
    plot(E_P{trialNo}(1:2:end,t),E_P{trialNo}(2:2:end,t),'r.-');
end
axis image