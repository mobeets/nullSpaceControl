function [LL, posterior, prior] = fmc_estep(U,Y,Xtarget,estParams)
% OUTPUTS
%   LL: Log-likelihood of the parameters in estParams
%   posterior
%    .mean: each element contains the posterior mean of the latent
%           variables for a particular trial in the format
%           [[x^1_{t-TAU}; ... x^1_{t+1}] ... [x^T_{t-TAU}; ... x^T_{t+1}]
%           where T is the number of timesteps in the corresponding trial
%    .cov:  Element j contains the posterior covariance of the latent 
%           variables for a trial j. Each element is sized
%           (2*(TAU+1)) x (2*(TAU+1)) x T, where T is the number of trials
%           in the corresponding trial
%   prior
%    .mean: Prior means of the latent variables (i.e., before conditioning 
%           on target location).  Same format as posterior.mean
%    .cov:  Prior covariance of the latent variables, which is independent
%           of the data (same covariance for all timesteps).
%

[C,G,const] = fastfmc_assemble_data(U,Y,Xtarget,estParams.TAU);
[LL, EqX, COVqX, EX, COVX] = fmc2clc_estep(estParams, U, Y, Xtarget, const.trial_map);

posterior.mean = EqX;
posterior.cov = COVqX;

prior.mean = EX;
prior.cov = COVX;