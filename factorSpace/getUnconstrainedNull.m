function unconstrainedNull_latents = getUnconstrainedNull(latents, extras, intuitiveMs, shuffleMs)

unconstrainedNull_latents = cell(1,3);
unconstrainedNull_latents{1} = latents{1};

T = size(latents{1},2);

for blk = 2:3
    
    if blk == 2
        dec = shuffleMs;
    elseif blk == 3
        dec = intuitiveMs;
    else
        error('Unsupported block')
    end
    
    nullBasis = null(dec.M2);
    
    numTimePts = size(latents{blk},2);
    
    curr_latents = nan(size(latents{blk}));
    
    for t = 1:numTimePts
        
       % Draw random timepoint from inuitive session (block 1)
       drawnLatent = latents{1}(:,randi(T));
       
       % Project into null space of current decoder
       zNull = projectFromBasis( projectToBasis( drawnLatent, nullBasis), nullBasis);
       
       % Compute necessary component in row space
       
       % Solve for row component "zRow"
       % Should satisfy
       %   M0 + M1*vPrev + M2*zRow = vReal
       %   nullBasis'*zRow = 0
       % There will be a unique solution given by solving
       %   min_(curr_vol) \|M0 + M1*vPrev + M2*zRow  - vReal\|^2
       %   s.t.    nullBasis'*zRow = 0
       % Rewrite this as
       %   min  (1/2)*zRow'*P*zRow+ q'*zRow
       %   s.t. C*zRow = 0
       % Where
       %   P = M2'*M2
       %   q = -M2'*(vReal-M0-M1*vPrev)
       %   C = nullBasis'
       % Solution satisfies
       %   [P C'; C 0]*[curr_vol; lagrangeVariable] = [-q; 0]
        
        vReal = extras{blk}.vReal(:,t);
        vPrev = extras{blk}.vPrev(:,t);
        
        P = dec.M2'*dec.M2;
        q = -dec.M2'*(vReal-dec.M0-dec.M1*vPrev);
        C = nullBasis';
        
        currVolAndLagrange = [P C'; C zeros(size(C,1))] \ [-q; zeros(size(C,1),1)];
        zRow = currVolAndLagrange(1:size(P,1));
        
        % Sanity checks
        
        assert(max(abs(dec.M2*zNull))<1e-6)
        assert(max(abs(nullBasis'*zRow))<1e-6)
        assert(norm(vReal - dec.M0 - dec.M1*vPrev - dec.M2*(zNull+zRow))<1e-6)
        
        curr_latents(:,t) = zRow+zNull;
       
       
    end
    
    unconstrainedNull_latents{blk} = curr_latents;
    
end