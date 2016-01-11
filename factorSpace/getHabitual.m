function habitual_latents = getHabitual(latents, theta, extras, intuitiveMs, shuffleMs)

habitual_latents = cell(1,3);
habitual_latents{1} = latents{1}; % don't predict anything different for intuitive block

THETA_TOLERANCE = 15; % 15 degrees

for blk = 2:3
    
    if blk == 2
        dec = shuffleMs;
    elseif blk == 3
        dec = intuitiveMs;
    else
        error('Unsupported block')
    end
    
    basis = getBasis(dec.M2'); assert(all(size(basis)==[10 10]))
%     rowBasis = basis(:,1:2);
    nullBasis = basis(:,3:end);
    clear basis
    
    prev_latents = habitual_latents{blk-1};
    pl_null = projectToBasis(prev_latents, nullBasis); % prev latents in null space of current decoder
%     pl_row  = projectToBasis(prev_latents, rowBasis);
    prev_thetas = theta{blk-1};
   
    curr_latents = nan(size(latents{blk}));
    curr_thetas = theta{blk};
    [N,T] = size(curr_latents);
    
    curr_null_low = nan(size(pl_null,1),T); % activity in null space in null coordinates
%     curr_null_high = nan(N,T);
    curr_row_high = nan(N,T); % activity in row space in high-d (10d) coordinates
    
    for t = 1:T
       
        ct = curr_thetas(t);
        
        % find idxs of other timepoints with similar thetas
        nearbyIdxs = getNearbyThetaIdxs(ct, prev_thetas, THETA_TOLERANCE);
        
        % pick a random one for curr_null
        t_ofNearbyTheta = nearbyIdxs(randi(length(nearbyIdxs)));
        curr_null_low(:,t) = pl_null(:,t_ofNearbyTheta);
        
        % solve for curr_row
        vPrev = extras{blk}.vPrev(:,t);
        vStar = extras{blk}.vStar(:,t);
        
        curr_row_high(:,t) = computeF_inRow(dec, vPrev, vStar);
        
        
    end
    
    % combine curr_row and curr_null
    curr_null_high = projectFromBasis(curr_null_low, nullBasis);
    curr_latents = curr_null_high + curr_row_high;
    
    % store in habitual_latents
    habitual_latents{blk} = curr_latents;
    
    
end


function fr = computeF_inRow(dec, vPrev, vStar)

% want f in row space such that M0+M1*vPrev+M2*f == vStar & nullM2*f == 0
 
M2 = dec.M2;
 
% min .5*fr'*H*fr + f'*x
H = M2'*M2;
f = -( (vStar-dec.M0-dec.M1*vPrev)'*M2 )';

% Ax <= b
A = [];
b = [];

% Aeq = beq
Aeq = null(M2)';
beq = zeros(size(Aeq,1),1);

options = optimset('Display','off','Algorithm','interior-point-convex');

[fr, ~, exitflag] = quadprog(H,f,A,b,Aeq,beq,[],[],[],options);

assert(exitflag==1)
assert(norm(M2*fr - (vStar-dec.M1*vPrev-dec.M0))<1e-4)
