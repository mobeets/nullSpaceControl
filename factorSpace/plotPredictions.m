%% overview

% 1. load and filter data
% 2. load and prep decoding params (calls simplifyKalman)
% 3. make predictions for the five hypotheses
% 4. calculate mean activity in null space of shuffle basis
% 5. calculate errors from true activity in null space

%% load/filter/prep

datestr = '20120601';

% Get subselected data
[spikes, latents, r, theta, extras] = get_subselect(datestr);

% Get decoding parameters
[ims_spk, sms_spk] = getMs_forSpikes_byDate(datestr); % for spikes
[ims_lat, sms_lat] = getMs_forLatents_byDate(datestr); % for latents
intuitiveMs.spikes = ims_spk;
intuitiveMs.latents = ims_lat;
shuffleMs.spikes = sms_spk;
shuffleMs.latents = sms_lat;

% Store real latents
predCounter = 1;
predictions = struct;
predictions(predCounter).latents = latents;
predictions(predCounter).name = 'real';

%% Make predictions

% Get & plot attractor=0 with nonnegative firing rates
fprintf('a=0 ')
nonnegative_0_t = true;
a_0_spikes_nn = getAttractor('zero', datestr, extras, ...
    intuitiveMs, shuffleMs, nonnegative_0_t, false);
a_0_latents_nn = cellfun(@(x) ...
    convertRawSpikesToRawLatents_byDate(x,datestr), a_0_spikes_nn, ...
    'UniformOutput', 0);
a_0_latents_nn{1} = latents{1};

predCounter = predCounter + 1;
predictions(predCounter).latents = a_0_latents_nn;
predictions(predCounter).name = 'Attractor 0';

%%
% Get & plot attractor=b0
fprintf('a=b0 ')
nonnegative_b0 = true;
a_b0_spikes_nn = getAttractor('baseline', datestr, extras, ...
    intuitiveMs, shuffleMs, nonnegative_b0, false);
a_b0_latents_nn = cellfun(@(x) ...
    convertRawSpikesToRawLatents_byDate(x,datestr), a_b0_spikes_nn, ...
    'UniformOutput', 0);
a_b0_latents_nn{1} = latents{1};

predCounter = predCounter + 1;
predictions(predCounter).latents = a_b0_latents_nn;
predictions(predCounter).name = 'Attractor b0';

%%
% Get & plot unconstrained null space
fprintf('unc ')
unconstrainedNull_latents = getUnconstrainedNull(latents, extras, ...
    intuitiveMs.latents, shuffleMs.latents);

predCounter = predCounter + 1;
predictions(predCounter).latents = unconstrainedNull_latents;
predictions(predCounter).name = 'Unconstrained Null';

%%
% Get & plot habitual
fprintf('hab ')
habitual_latents = getHabitual(latents, theta, extras, ...
    intuitiveMs.latents, shuffleMs.latents);

predCounter = predCounter + 1;
predictions(predCounter).latents = habitual_latents;
predictions(predCounter).name = 'Habitual';

%%
% Get & plot volitional in intuitive row space
fprintf('vol-row ')
volitional_intuitiveRow_latents = get2dVolitional(latents, theta, ...
    extras, intuitiveMs.latents.M2', ...
    intuitiveMs.latents, shuffleMs.latents);

predCounter = predCounter + 1;
predictions(predCounter).latents = volitional_intuitiveRow_latents;
predictions(predCounter).name = 'Volitional - Row';

%% Plot sticks

% Get basis for plots
% Need to plot in intuitive row basis and shuffle null basis
intuitiveBasis = getBasis(intuitiveMs.latents.M2');
shuffleBasis = getBasis(shuffleMs.latents.M2');

% Plot actual activity
plotStructures = plotActivity(latents, theta, ...
    intuitiveBasis, shuffleBasis, 'recorded');
plotStructures(end+1) = plotActivity(a_0_latents_nn, theta, ...
    intuitiveBasis, shuffleBasis, 'minimal');
plotStructures(end+1) = plotActivity(a_b0_latents_nn, theta, ...
    intuitiveBasis, shuffleBasis, 'baseline');
plotStructures(end+1) = plotActivity(unconstrainedNull_latents, theta, ...
    intuitiveBasis, shuffleBasis, 'unconstrained');
plotStructures(end+1) = plotActivity(habitual_latents, theta, ...
    intuitiveBasis, shuffleBasis, 'habitual');
plotStructures(end+1) = plotActivity(volitional_intuitiveRow_latents, ...
    theta, intuitiveBasis, shuffleBasis, 'volitional');

%% JAH note: Each of the above calls to plotActivity returns this:
% plottedVals = cell(2,5);
% for dim = 3:10
%     [activityMean, ~] = getMeanAndSE(latents,theta,shuffleBasis(:,dim));
%     plottedVals{dim} = activityMean;
% end
% plotStructure = struct();
% plotStructure.vals = plottedVals';
% plotStructure.name = figureName;

%% Plot Errors

bootstrapErrors_forDAP(predictions, theta, shuffleBasis(:,3:10));
fprintf('\n')
