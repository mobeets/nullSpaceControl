function D = summarizeScores(D)
% add a summary object that calculates bootstrap errs and adds to D.hyps?
% can skip duplicates using 'timestamp' field in scores
    Hs = D.hyps;
    scs = D.scores;    
    [nreps, nhyps] = size(scs);
    for ii = 1:nhyps
        sc = scs(:,ii);
        tms = {sc.timestamp};
        % find unique objs using tms
        % now take mean of each score obj, and calc SE as well
    end    
    D.score = Hs;
end
