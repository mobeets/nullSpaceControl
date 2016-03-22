function [estParams, LL] = velime_fit(U, Y, Xtarget, TAU, varargin)
% [estParams, LL] = velime_fit(U, Y, Xtarget, TAU,...)

startTime = tic;

initialize_velime

if verbose
    fprintf('Beginning velime EM\n')
end

iter_times = [];


while (max_iters>0)
    iters_completed_start_time = tic;
    
    LLold = LLi;
    
    % =======
    % E-step
    % =======
    [LLi, E_X_posterior, COV_X_posterior]  = velime_estep(C, G, estParams, const);
    
    LL = [LL LLi];
        
    if mod(iters_completed,50)==0 && iters_completed>0
        if verbose
            fprintf('velime(TAU=%d) iters: %d, Mean iter time: %1.1e, diffLL(n): %.3e\n', TAU, iters_completed,mean(iter_times), LLi-LLold);
        end
    end
    
    % =======
    % Check for convergence
    % =======
    if iters_completed>1 && LLi < LLold && abs(LLold-LLi)>1e-10
        fprintf('VIOLATION velime(TAU=%d) iters: %d: %g\n', TAU, iters_completed, LLi-LLold);
        try
            plot(LL); drawnow;
        catch
            % do nothing
        end
    end
    if (iters_completed>min_iters) && (LLi>LLold) && (LLi - LLold < tol)
        fprintf('velime(TAU=%d) converged after %.2f seconds: %d iters\n', TAU, toc(startTime),iters_completed);
        break; % convergence
    elseif iters_completed>=max_iters
        if verbose
            fprintf('velime(TAU=%d) iter limit reached, aborting after %.2f seconds, diffLL(n): %.3e\n', TAU, toc(startTime), LLi-LLold);
        end
        break
    end
    
    % =======
    % M-step
    % =======
    M_Params_fastfmc = velime_mstep_MParams(E_X_posterior, COV_X_posterior, C, const);
    ALPHA_Params = velime_mstep_alphaParams(G, E_X_posterior, COV_X_posterior, const);
    
    estParams.A = M_Params_fastfmc.M1;
    estParams.B = M_Params_fastfmc.M2;
    estParams.b0 = M_Params_fastfmc.m0;
    estParams.W_v = M_Params_fastfmc.V;
    
    estParams.alpha = ALPHA_Params.alpha;
    estParams.R = ALPHA_Params.R;
    
    iters_completed = iters_completed + 1;
    iter_times(iters_completed) = toc(iters_completed_start_time);
end

end