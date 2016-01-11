function volitional_latents = get2dVolitional(latents, theta, extras, volSpace, intuitiveMs, shuffleMs)

% questions:
%   How do we get target-conditioned distributions in non-volitional space?
%       Idea: use distributions during intuitive session; only predict shuffle and washout

% At each t
%   draw non-volitional component from distribution to target
%   choose volitional component in volSpace so that ideal movement is performed
%   combine the two

THETA_TOLERANCE = 15; % 15 degrees

% Orthogonalize volSpace and assert 2 dimensionality
volSpace = orth(volSpace);
assert(all(size(volSpace)==[10 2]))

% Find non-volitional space
nonvolSpace = null(volSpace');
assert(all(size(nonvolSpace)==[10 8]))

% Get target-conditioned distributions in this space
% % uniqueTargets = unique(extras{1}.targetAngles);
% % targetConditionedNonvolitionalDistributions = cell(1,8);
% % for targ = 1:8
% %    
% %     idxsToTarg = (extras{1}.targetAngles==uniqueTargets(targ));
% %     latentsToTarg = latents{1}(:,idxsToTarg);
% %     
% %     % project to nonvolitional space
% %     projectedToNonvolSpace = projectToBasis(latentsToTarg,nonvolSpace);
% %     
% %     % project back to hi-d space
% %     targetConditionedNonvolitionalDistributions{targ} = projectFromBasis(projectedToNonvolSpace, nonvolSpace);
% %     
% % end

% For shuffle and washout
%   draw from target-conditioned distribution
%   choose volitional component as necessary
%   combine two components

volitional_latents = cell(1,3);
volitional_latents{1} = latents{1};

for blk = 2:3
   
    if blk == 2
        dec = shuffleMs;
    elseif blk == 3
        dec = intuitiveMs;
    else
        error('Unsupported block')
    end
    
    numTimePts = size(latents{blk},2);
    nonvolLatents = nan(10,numTimePts);
    volLatents = nan(10,numTimePts);
    
    
    for t = 1:numTimePts
       
        ct = theta{blk}(t);
        
        % find idxs of other timepoints with similar thetas
        nearbyIdxs = getNearbyThetaIdxs(ct, theta{1}, THETA_TOLERANCE);
        
        % pick a random one for curr_null
        drawnLatent = latents{1}(:,nearbyIdxs(randi(length(nearbyIdxs))));
        
        curr_nonvol = projectFromBasis( projectToBasis(drawnLatent, nonvolSpace), nonvolSpace);
        
% %         % Get target idx
% %         targAngle = extras{blk}.targetAngles(t);
% %         targIdx = find(uniqueTargets == targetAngle);
% %         
% %         nonvolLatents = drawFrom(targetConditionedNonvolitionalDistributions{targIdx});
        
        % Sanity checks on curr_nonvol
        assert(max(abs(volSpace'*curr_nonvol))<1e-6)
        
        nonvolLatents(:,t) = curr_nonvol;
        

        % Solve for volitional component "curr_vol"
        % Should satisfy
        %   z = curr_nonvol + curr_vol
        %   M0 + M1*vPrev + M2*z = vReal
        %   nonvolSpace'*curr_vol = 0
        % There will be a unique solution given by solving
        %   min_(curr_vol) \|M0 + M1*vPrev + M2*curr_nonvol + M2*curr_vol - vReal\|^2
        %   s.t.    nonvolSpace'*curr_vol = 0
        % Rewrite this as
        %   min  (1/2)*curr_vol'*P*curr_vol + q'*curr_vol
        %   s.t. C*curr_vol = 0
        % Where
        %   P = M2'*M2
        %   q = -M2'*(vReal-M0-M1*vPrev-M2*curr_nonvol)
        %   C = nonvolSpace'
        % Solution satisfies
        %   [P C'; C 0]*[curr_vol; lagrangeVariable] = [-q; 0]
        
        vReal = extras{blk}.vReal(:,t);
        vPrev = extras{blk}.vPrev(:,t);
        
%         curr_vol = dec.M2 \ (vReal - dec.M0 - dec.M1*vPrev - dec.M2*nonvolLatents(:,t));
%         curr_vol = projectFromBasis( projectToBasis(curr_vol, volSpace), volSpace);
        P = dec.M2'*dec.M2;
        q = -dec.M2'*(vReal-dec.M0-dec.M1*vPrev-dec.M2*nonvolLatents(:,t));
        C = nonvolSpace';
        
        currVolAndLagrange = [P C'; C zeros(size(C,1))] \ [-q; zeros(size(C,1),1)];
        curr_vol = currVolAndLagrange(1:size(P,1));
        
        % Sanity checks on curr_vol
        assert(norm(vReal - dec.M0 - dec.M1*vPrev - dec.M2*curr_vol - dec.M2*nonvolLatents(:,t))<1e-6)
        assert(max(abs(nonvolSpace'*curr_vol))<1e-6)
        
        volLatents(:,t) = curr_vol;
        
        
    end
    
    volitional_latents{blk} = volLatents + nonvolLatents;
    
    
end

function x = drawFrom(X)

idx = randi(size(X,2));
x = X(:,idx);