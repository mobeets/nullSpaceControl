tol = 10e-8;
max_iters = 1e5;
min_iters = 10;
DEBUG = false;
verbose = false;
INIT_METHOD = 'target_regression';
INIT_PARAMS = NaN;
assignopts(who, varargin);

[C,G,const] = velime_assemble_data(U,Y,Xtarget,TAU);

% Initialization of parameters
% For {M1,M2,m0}
%
% TARGET_REGRESSION -- Regress target direction against spikes.
% This will give the same model parameters in each tau model (i.e.
% initialization doesn't depend on tau.  This may make it hard to identify
% tau based on this initialization, unless the L initialization
% differentiates between tau "enough").

% Should really initialize using KF decoding parameters

switch lower(INIT_METHOD)
    case 'target_regression'
        A = eye(2);
        [B, b0, W_v] = target_regression(U,Y,Xtarget);
        estParams.A = A;
        estParams.B = B;
        estParams.b0 = b0;
        estParams.W_v = W_v;
        estParams.W_p = 0*W_v;
        estParams.TAU = TAU;
        estParams.dt = 1;
        % alphas initialized below
    case 'current_regression'
        [A, B, b0, W_v] = current_regression(U,Y,Xtarget);
        estParams.A = 0*A;
        estParams.B = B;
        estParams.b0 = b0;
        estParams.W_v = W_v;
        estParams.W_p = 0*W_v;
        estParams.TAU = TAU;
        estParams.dt = 1;
        % alphas initialized below
    case 'random'
        % Start EM at 500 random initialization.  Update each
        % initialization through 100 EM iterations.  Of these
        % parameter sets, choose the 50 with the highest training
        % LL, and continue to update those parameters for 100 more
        % iterations.  Select the max LL parameter set, and update those
        % for a total of max_iters total EM iterations.
        NUM_RANDOM_INITIALIZATIONS = [500];
        NUM_INITIAL_ITERS = [100];
        velime_args = {'tol',tol,'min_iters',min_iters,'DEBUG',DEBUG,'verbose',false};
        [estParams, LL, randParams, randParamsLL] = velime_randInit(C,U,Y,Xtarget,TAU,const.xDim,velime_args,...
            'NUM_RANDOM_INITIALIZATIONS',NUM_RANDOM_INITIALIZATIONS,...
            'NUM_INITIAL_ITERS',NUM_INITIAL_ITERS,...
            'verbose',verbose);
    case 'init_params'
        estParams = INIT_PARAMS;
        estParams.TAU = TAU;
    otherwise
        error('Unsupported initialization method');
end

if ~isfield(estParams,'alpha')
    %% Initialize alpha's using prior distribution over latents
    [E_X, COV_X] = velime_prior_expectation(C, estParams);
    init_alphaParams = velime_mstep_alphaParams(G, E_X, repmat(COV_X,[1 1 const.T]), const);
    
    %% Assign estParams
    estParams.alpha = init_alphaParams.alpha;
    estParams.R = init_alphaParams.R;
end

if strcmpi(INIT_METHOD,'random')
    % LL is set in switch statement
    LLi = LL(end);
    iters_completed = length(LL);
else
    iters_completed = 0;
    LLi   = 0;
    LL    = [];
end