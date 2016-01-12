function [spikes, r, theta, extras] = subselect_timepoints(simpleData, ...
    minDistanceFromTarget, maxDistanceFromTarget, maxAngularError, ...
    candidateTrials)

IDEAL_SPEED = 175;

% Collect spikes and behavior from candidate trials
all_spikes = subCellArray(simpleData.spikeBins, candidateTrials);
all_spikes = cellfun(@(x) x', all_spikes, 'UniformOutput', 0);

pos = subCellArray(simpleData.decodedPositions, candidateTrials);
pos = cellfun(@(x) x', pos, 'UniformOutput', 0);

vel = subCellArray(simpleData.decodedVelocities, candidateTrials);
vel = cellfun(@(x) x', vel, 'UniformOutput', 0);

targets = simpleData.targetLocations(candidateTrials,1:2)';
ta = simpleData.targetAngles(candidateTrials)';

% Create output variables
numTrials = length(candidateTrials);
numNeurons = size(all_spikes{1},1);

spikesCell = cell(1,numTrials);
rCell = cell(1,numTrials);
thetaCell = cell(1,numTrials);
targetAnglesCell = cell(1,numTrials);
angularErrorsCell = cell(1,numTrials);

vStar = cell(1,numTrials);
vReal = cell(1,numTrials);
vPrev = cell(1,numTrials);

% Loop through trials and maintain valid data points
for trl = 1:numTrials
   
    curr_spikes = nan(numNeurons, 0);
    curr_r = [];
    curr_theta = [];
    curr_ta = [];
    curr_angularError = [];
    curr_vs = nan(2,0);
    curr_v = nan(2,0);
    curr_vp = nan(2,0);
    
    numTimePts = size(all_spikes{trl},2);
    
    curr_target = targets(:,trl);
    curr_pos = pos{trl};
    curr_vel = vel{trl};
%     curr_dists = sqrt( sum( (curr_pos - repmat(curr_target,1,numTimePts-1)).^2 ) );
%     
%     t_valid_dists = find(curr_dists >= minDistanceFromTarget);
    
    for t = 1:numTimePts-1
       
        % Compute angular error
        p_t = curr_pos(:,t);
        p_tp1 = curr_pos(:,t+1);
        movementVector = p_tp1-p_t;
        
        vec2target = curr_target-p_t;
        
        r_t = norm(vec2target);
        theta_t = computeAngle(vec2target, [1; 0]);
        
        angError_t = computeAngle(movementVector, vec2target);
        
        if r_t >= minDistanceFromTarget && r_t <= maxDistanceFromTarget
            if abs(angError_t) <= maxAngularError
                
                spike_t = all_spikes{trl}(:,t+1);
                
                % spike used to move from p_t to p_tp1
                curr_spikes = [curr_spikes, spike_t];
                curr_r = [curr_r, r_t];
                curr_theta = [curr_theta, theta_t];
                
                curr_ta = [curr_ta, ta(trl)];
                curr_angularError = [curr_angularError, angError_t];
                
                curr_v = [curr_v curr_vel(:,t)];
                curr_vp = [curr_vp curr_vel(:,t-1)];
                curr_vs = [curr_vs IDEAL_SPEED*vec2target/norm(vec2target)];
                
            end
        end
            
        
    end
    
    spikesCell{trl} = curr_spikes;
    rCell{trl} = curr_r;
    thetaCell{trl} = curr_theta;
    
    targetAnglesCell{trl} = curr_ta;
    angularErrorsCell{trl} = curr_angularError;
    vStar{trl} = curr_vs;
    vReal{trl} = curr_v;
    vPrev{trl} = curr_vp;
    
end

spikes = cell2mat(spikesCell);
r = cell2mat(rCell);
theta = cell2mat(thetaCell);

extras = struct();
extras.targetAngles = cell2mat(targetAnglesCell);
extras.angularErrors = cell2mat(angularErrorsCell);
extras.vStar = cell2mat(vStar);
extras.vReal = cell2mat(vReal);
extras.vPrev = cell2mat(vPrev);
