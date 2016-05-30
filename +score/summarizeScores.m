function D = summarizeScores(D)
% add a summary object that calculates bootstrap errs and adds to D.hyps?
% can skip duplicates using 'timestamp' field in scores
    Hs = D.hyps;
    scs = D.scores;    
    [nreps, nhyps] = size(scs);
    for ii = 1:nhyps
        sc = scs(:,ii);
        tms = {sc.timestamp}; % id for reps
        inds = grpstats(1:numel(tms), tms', @min); % find duplicates
        
        fns = setdiff(fieldnames(sc), {'name', 'grps', 'timestamp'});
        for jj = 1:numel(fns)
            items = cat(3, sc.(fns{jj})); % stack reps
            items = items(:,:,inds); % remove duplicates
            mu = nanmean(items, 3); % avg across reps
            se = 1.96*nanstd(items, [], 3)/sqrt(size(items,3));
            Hs(ii).(fns{jj}) = mu;
            Hs(ii).([fns{jj} '_se']) = se;
        end
    end    
    D.score = Hs;
end
