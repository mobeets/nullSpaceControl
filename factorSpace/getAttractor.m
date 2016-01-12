function signal = getAttractor(type, date, extras, ...
    intuitiveMs, shuffleMs, nonnegative, inLatentSpace)
% type is 'zero' or 'baseline'

if nargin == 4
    inLatentSpace = false; % require spike count to be in FA manifold?
end

if ~inLatentSpace
    intuitiveMs = intuitiveMs.spikes;
    shuffleMs = shuffleMs.spikes;
else
    intuitiveMs = intuitiveMs.latents;
    shuffleMs = shuffleMs.latents;
end

signalDim = size(intuitiveMs.M2,2);
assert(signalDim==10 || signalDim>80)

signal = cell(1,3);

DESIRED_OUTPUT = false; % use vStar? if false, use vReal

[~, ~, ~, ALinv, mu] = convertRawSpikesToRawLatents_byDate([], date);

%% --- Optimization variables ---

LB = [];
UB = [];
x0 = [];

if ~inLatentSpace
    
    H = eye(signalDim);
    
    if strcmp(type,'zero')
        f = [];
    elseif strcmp(type,'baseline')
        f = -mu;
    else
        error('invalid type')
    end
    
    if nonnegative % A*x <= b
        A = -eye(signalDim);
        b = zeros(signalDim,1);
    else
        A = [];
        b = [];
    end

else
    
    H = ALinv'*ALinv;
    
    if strcmp(type,'zero')
        f = ALinv'*mu; % this seems odd, but is correct
    elseif strcmp(type,'baseline')
        f = [];
    else
        error('invalid type')
    end
    
    if nonnegative
        A = -ALinv;
        b = mu;
    else
        A = [];
        b = [];
    end
    
end

%%

options = optimset('Algorithm','interior-point-convex','Display','off');
for blk = 1:3
    
    vPrev = extras{blk}.vPrev;
    if DESIRED_OUTPUT
        vOutput = extras{blk}.vStar;
    else
        vOutput = extras{blk}.vReal;
    end
    
    T = size(vPrev,2);
    assert(size(vOutput,2)==T)
    
    % Predict signal at each time point from
    % min \|f\|_2^2
    %    s.t. f>=0
    %         M0+M1*vPrev+M2*f=vStar
    s = nan(signalDim,T);
    
    if blk == 1 || blk == 3
        dec = intuitiveMs;
    elseif blk == 2
        dec = shuffleMs;
    end
    
    Aeq = dec.M2;
    
    for t = 1:T
        
        if mod(t,1000)==0
            fprintf('Block %i: %i of %i\n',blk, t, T);
        end
        
        beq = vOutput(:,t)-dec.M0-dec.M1*vPrev(:,t);
        
        [sg, ~, exitflag, output] = quadprog(H,f,A,b,Aeq,beq,LB,UB,x0,options);
        
        if exitflag == 0 % max iter exceeded
            fprintf('Increasing TolFun to 1e-3 from 1e-8... ')
            options2 = optimset(options, 'TolFun', 1e-3);
            [sg, ~, exitflag, output] = quadprog(H,f,A,b,Aeq,beq,LB,UB,x0,options2);
            fprintf('done!\n')
        end
        
        assert(exitflag==1)
        s(:,t) = sg;
        
    end
    
    signal{blk} = s;
    
end