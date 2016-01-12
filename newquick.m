%% overview

% 1. load and filter data
% 2. load and prep decoding params (calls simplifyKalman)
% 3. make predictions for the five hypotheses
% 4. calculate mean activity in null space of shuffle basis
% 5. calculate errors from true activity in null space

%% load and prepare data

d = io.loadDataByDate('20120601');
d.params = io.loadParams(d);
d = io.filterDataByBlock(d);
d.latents = io.rawSpikesToLatentsByBlock(d);
% get decoding params

%% make predictions

hyps(1).name = 'observed';
hyps(1).latents = d.latents;
