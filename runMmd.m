
NB = D.blocks(2).fDecoder.NulM2;
Y1 = D.hyps(1).latents*NB;
Y2 = D.hyps(4).latents*NB;
Y = [Y1; Y2];
labels = ones(size(Y,1),1);
labels(size(Y1,1)+1:end) = -1;
clear global Kxx
[h, info] = mmd(Y, labels, .05, 'bootstrap');

% 20120709
%
% PRUNING
% --------
% h =
% 
%      1     1
% 
% info.mmd
% 
% ans = 
% 
%        val: 0.0061
%      bound: 1.9056e-04
%          H: 1
%     method: 'bootstrap'
% 
% info.mmd_rad
% 
% ans = 
% 
%       val: 0.0789
%     bound: 0.0656
%         H: 1

% CLOUD
% --------
% h =
% 
%      1     1
% 
% info.mmd
% 
% ans = 
% 
%        val: 0.0085
%      bound: 1.4121e-04
%          H: 1
%     method: 'bootstrap'
% 
% info.mmd_rad
% 
% ans = 
% 
%       val: 0.0928
%     bound: 0.0656
%         H: 1
