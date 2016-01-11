function [activityMean, activitySE, activityCov, binnedLatents, binnedScores] = getMeanAndSE(latents,theta,basisVecs)
% if basisVecs has one column, return activityMean and activitySE
% else return covariance structure along columns of basisVecs

assert(size(basisVecs,1)==10)
% assert(all(size(basisVecs)==[10 1])) % must be column vector in R^10
assert(abs(norm(basisVecs)-1)<1e-8) % must be unit vector

numVecs = size(basisVecs,2);

NUM_THETA_BINS = 8; assert(NUM_THETA_BINS>=8 && mod(log2(NUM_THETA_BINS),1)==0) % needs to divide evenly


binwidth = 360/NUM_THETA_BINS;
theta_bin_centers = 0:binwidth:360; % 8 bins

activityMean = [];%nan(3,NUM_THETA_BINS); %first and last value will be identical
activitySE = [];%nan(3,NUM_THETA_BINS); % same for standard error
activityCov = [];%cell(3,NUM_THETA_BINS);

newTheta = reformatTheta(theta, theta_bin_centers);

binnedLatents = cell(3,NUM_THETA_BINS);
binnedScores = cell(3,NUM_THETA_BINS);

for blk = 1:3
    for bin = 1:NUM_THETA_BINS
        
        % Get theta boundaries (paying special attention to edge cases)
        L = theta_bin_centers(bin)-binwidth/2;
        U = theta_bin_centers(bin)+binwidth/2;
        idxs = L < newTheta{blk} & newTheta{blk} <= U;
        
        % Subselect latents & get scores
        currLatents = latents{blk}(:,idxs);
        currScores = basisVecs'*currLatents;
        
        binnedLatents{blk,bin} = currLatents;
        binnedScores{blk,bin} = currScores;
        
        if numVecs == 1
            % Compute mean on basisVec
            activityMean(blk,bin) = mean(currScores);
            activitySE(blk,bin) = std(currScores)/sqrt(length(currScores));
            
        else
            
            activityCov{blk,bin} = cov(currScores');
            
        end
        
    end
end