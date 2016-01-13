function tblk = getSuccessfulTrialsByBlock(D)
% 
% tblk [ntrials x 1] - nan for unsuccessful, 1 for block 1, etc.
% 

    ntrials = length(D.simpleData.shuffleIndices);
    isShuffle = ~isnan(D.simpleData.shuffleIndices)';
    firstShuffleTrial = find(isShuffle, 1, 'first');
    firstWashoutTrial = find(~isShuffle & ...
        1:ntrials > firstShuffleTrial, 1, 'first');

    tblk = nan(ntrials, 1);
    tblk(1:firstShuffleTrial-1) = 1;
    tblk(D.params.START_SHUFFLE:firstWashoutTrial-1) = 2;
    tblk(D.params.START_WASHOUT:end) = 3;
    tblk(~D.simpleData.trialStatus) = nan; % unsuccessful trials

end
