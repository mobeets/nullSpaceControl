
d = load('data/20120303simpleData_combined.mat');
d = d.simpleData;

%%

B1 = d.nullDecoder.H; % [10 x 2]
B2 = [];
NB1 = [];
NB2 = [];

Y = d.spikeBins; % cell array, [n x 86]
Z = []; % use d.nullDecoder.FactorAnalysisParams

%% Subselecting data
% We subselect only those data points for which:
% (1) the decoded velocity is within 20 degrees of the target 
% direction
% (2) the cursor is between 125mm and 50mm from the target (this 
% assures both that the cursor has not moved backward and that we can 
% mitigate potential reward-expectation artifacts)
% (3) if the data point comes from the second mapping, it occurs in 
% the 201st trial or later to mitigate mapping-transition effects [12].

MapInd = []; % should be [n x 2] containing 1 or 2 for T1 or T2
Pos = d.decodedPositions; % cell array, [n x 2]

%% Partitioning data
% We therefore partition our data into a data set from the 
% mapping 1 block, T1 and a data set from the mapping 2 block, 
% T2, which contain the tuples (?zt,xt,?t). The variable ?t is 
% the signed angle from the cursor position to the target location 
% at time t.

% want to create something like d above, but only for subselected trials
T1 = [];
T2 = [];

%% Making predictions

% Actual firing rate
Act.Z = Z;

% Predicted firing rates
Preds.MinFire.Z = pred.minFireFit();
Preds.BaseFire.Z = pred.baseFireFit();
Preds.UncCont.Z = pred.uncContFit();
Preds.HabCont.Z = pred.habContFit();
Preds.VolCont.Z = pred.volContFit();

%% Evaluating predictions

[Act, Preds] = pred.nullActivity(T1, T2, NB2, Act, Preds);
[errOfMeans, covRatio] = score.scoreAll(Act, Preds);

%% Visualizing predictions

% Plot Actual vs. Predicted, Map1->Map2, for each null column of B2

% Plot error of means

% Plot covariance ratios
