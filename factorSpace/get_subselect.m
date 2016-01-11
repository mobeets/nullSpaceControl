function [spikes, latents, r, theta, extras] = get_subselect(date, plot)

% Goal: choose subselection criterion that applies across multiple datasets

% date = '20120601';
% date = '20120525';
% date = '20131125';
% date = '20131205';

if nargin < 2
    plot = false;
end

data_directory = getpref('factorSpace', 'data_directory');

%% Load data
if strcmp(date,'20120525')
    load([data_directory '/Jeffy/20120525/20120525simpleData.mat']);
%     d = load([code_directory 'research/attractor/data/p20120525.mat']);
    load([data_directory '/Jeffy/20120525/kalmanInitParamsFA20120525(1).mat'])
    START_SHUFFLE = 700;
    START_WASHOUT = 1600;
elseif strcmp(date, '20120601')
    load([data_directory '/Jeffy/20120601/20120601simpleData_combined.mat']);
%     d = load([code_directory 'research/attractor/data/p20120601.mat']);
    load([data_directory '/Jeffy/20120601/kalmanInitParamsFA20120601(2).mat'])
    START_SHUFFLE = 450;
    START_WASHOUT = 1330;
elseif strcmp(date, '20131125')
    load([data_directory '/Lincoln/20131125/20131125simpleData.mat']);
%     d = load([code_directory 'research/attractor/data/p20131125L.mat']);
    load([data_directory '/Lincoln/20131125/kalmanInitParamsFA20131125_11.mat'])
    START_SHUFFLE = 450;
    START_WASHOUT = 800;
elseif strcmp(date, '20131205')
    load([data_directory '/Lincoln/20131205/20131205simpleData.mat']);
%     d = load([code_directory 'research/attractor/data/p20131205L.mat']);
    load([data_directory '/Lincoln/20131205/kalmanInitParamsFA20131205_11.mat'])
    START_SHUFFLE = 400;
    START_WASHOUT = 800;
else
    error('Date not supported yet')
end



MIN_DISTANCE = 50;
MAX_DISTANCE = 125;
MAX_ANGULAR_ERROR = 20;

numTrials = length(simpleData.shuffleIndices);
firstShuffleTrial = find(~isnan(simpleData.shuffleIndices),1,'first');
firstWashoutTrial = find(isnan(simpleData.shuffleIndices)' & 1:numTrials > firstShuffleTrial,1,'first');


trials = {1:firstShuffleTrial-1, START_SHUFFLE:firstWashoutTrial-1, START_WASHOUT:numTrials};
successfulTrials = find(simpleData.trialStatus);

if plot
    figure;
end

spikes = cell(1,3);
r = cell(1,3);
theta = cell(1,3);
extras = cell(1,3);

latents = cell(1,3);

for blk = 1:3
    
    
    blockTrials = trials{blk};
    candidateTrials = intersect(successfulTrials, blockTrials);
    
    [spikes{blk}, r{blk}, theta{blk}, extras{blk}] = subselect_timepoints(simpleData, MIN_DISTANCE, MAX_DISTANCE, MAX_ANGULAR_ERROR, candidateTrials);
    
    latents{blk} = convertRawSpikesToRawLatents(simpleData,spikes{blk});
    
    if plot
        
        fprintf('%i timepoints reported\n',length(r))
        
        subplot(2,3,1), hist(r,2.5:5:MAX_DISTANCE)
        subplot(2,3,4), hist(theta, -179:2:179)
        
        xx = r.*cosd(theta);
        yy = r.*sind(theta);
        colors = getColors;
        subplot(2,3,[2 3 5 6])
        ta = extras.targetAngles;
        uta = unique(extras.targetAngles);
        for idx = 1:length(uta)
            curr_idxs = ta==uta(idx);
            if idx == 2
                hold on
            end
            plot(xx(curr_idxs),yy(curr_idxs),'o','color',colors(idx,:))
        end
        axis square
        hold off
        
        pause
        
    end
    
end