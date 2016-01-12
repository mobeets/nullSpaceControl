function [spikes, r, theta, extras] = filterTrialData(D, tidx)

simpleData = D.simpleData;
minDistanceFromTarget = D.params.MIN_DISTANCE;
maxDistanceFromTarget = D.params.MAX_DISTANCE;
maxAngularError = D.params.MAX_ANGULAR_ERROR;
IDEAL_SPEED = D.params.IDEAL_SPEED;

% Collect spikes and behavior from candidate trials

candidateTrials = 1:numel(tidx);
candidateTrials = candidateTrials(tidx);
all_spikes = subCellArray(simpleData.spikeBins, candidateTrials);
pos = subCellArray(simpleData.decodedPositions, candidateTrials);
vel = subCellArray(simpleData.decodedVelocities, candidateTrials);

targets = simpleData.targetLocations(tidx, 1:2)';
ta = simpleData.targetAngles(tidx)';

% Create output variables

ntrials = sum(tidx);
ncells = size(all_spikes{1},2);

spikesCell = cell(1,ntrials);
rCell = cell(1,ntrials);
thetaCell = cell(1,ntrials);
targetAnglesCell = cell(1,ntrials);
angularErrorsCell = cell(1,ntrials);

vStar = cell(1,ntrials);
vReal = cell(1,ntrials);
vPrev = cell(1,ntrials);

% Loop through trials and maintain valid data points
for tr = 1:ntrials
   
    curr_spikes = nan(ncells, 0);
    curr_r = [];
    curr_theta = [];
    curr_ta = [];
    curr_angularError = [];
    curr_vs = nan(2,0);
    curr_v = nan(2,0);
    curr_vp = nan(2,0);
    
    ntimes = size(all_spikes{tr},1);
    
    curr_target = targets(:,tr);
    curr_pos = pos{tr}';
    curr_vel = vel{tr}';

    for t = 1:ntimes-1
       
        % Compute angular error
        p_t = curr_pos(:,t);
        p_tp1 = curr_pos(:,t+1);
        movementVector = p_tp1-p_t;
        
        vec2target = curr_target-p_t;
        
        r_t = norm(vec2target);
        theta_t = tools.computeAngle(vec2target, [1; 0]);
        
        angError_t = tools.computeAngle(movementVector, vec2target);
        
        if r_t >= minDistanceFromTarget && ...
            r_t <= maxDistanceFromTarget && ...
            abs(angError_t) <= maxAngularError
                
            spike_t = all_spikes{tr}(t+1,:)';

            % spike used to move from p_t to p_tp1
            curr_spikes = [curr_spikes, spike_t];
            curr_r = [curr_r, r_t];
            curr_theta = [curr_theta, theta_t];

            curr_ta = [curr_ta, ta(tr)];
            curr_angularError = [curr_angularError, angError_t];

            curr_vs = [curr_vs IDEAL_SPEED*vec2target/norm(vec2target)];
            curr_v = [curr_v curr_vel(:,t)];
            curr_vp = [curr_vp curr_vel(:,t-1)];                

        end    
    end
    
    spikesCell{tr} = curr_spikes;
    rCell{tr} = curr_r;
    thetaCell{tr} = curr_theta;
    targetAnglesCell{tr} = curr_ta;
    angularErrorsCell{tr} = curr_angularError;
    vStar{tr} = curr_vs;
    vReal{tr} = curr_v;
    vPrev{tr} = curr_vp;
    
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

end
