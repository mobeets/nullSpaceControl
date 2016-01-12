function tblk = getSuccessfulTrialsByBlock(D)
% 
% tblk [ntrials x 1] - nan for unsuccessful, 1 for block 1, etc.
% 

    ntrials = length(D.simpleData.shuffleIndices);
    firstShuffleTrial = find(~isnan(D.simpleData.shuffleIndices), 1, 'first');
    firstWashoutTrial = find(isnan(D.simpleData.shuffleIndices)' & ...
        1:ntrials > firstShuffleTrial, 1, 'first');

    tblk = nan(ntrials, 1);
    tblk(1:firstShuffleTrial-1) = 1;
    tblk(D.params.START_SHUFFLE:firstWashoutTrial-1) = 2;
    tblk(D.params.START_WASHOUT:end) = 3;
    tblk(~D.simpleData.trialStatus) = nan; % unsuccessful trials

end
