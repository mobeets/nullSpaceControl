function [U, Y, T] = prep(D, bind)
% U = [1 ntrials] cell, U(1) = [ncells ntimes] double
% Y = [1 ntrials] cell, Y(1) = [2 ntimes] double
% T = [1 ntrials] cell, T(1) = [2 1] double
    if nargin < 2
        bind = 1;
    end
    
    B = D.trials;
    B.spikes(2:end,:) = B.spikes(1:end-1,:);
    ib = B.block_index == bind;
    ib = ib & B.isCorrect;

    ts = B.trial_index;
    trs = sort(unique(ts(ib)));
    ntrs = numel(trs);
    U = cell(1, ntrs);
    Y = cell(size(U));
    T = cell(size(U));
    for ii = 1:ntrs
        it = (ts == trs(ii)) & ib;
        
        % ensure all times are accounted for; remove first 6 time-points
        tms = B.time(it);
        ntms = max(tms);        
        assert(all(sort(tms)' == 1:ntms));
        it = B.time >= 7 & it;

        % target position
        cT = B.target(find(it, 1, 'first'),:)'; % 1x2

        % cursor position
        cY = B.pos(it,:)';

        % spikes
        cU = B.spikes(it,:)';

        % remove columns with nans
        assert(not(any(isnan(cY(:)))));
        assert(not(any(isnan(cT(:)))));
        if any(isnan(cU(:)))
            ixNan = any(isnan(cU));
            indFirstNan = find(ixNan, 1, 'first');
            numNonNans = sum(~ixNan(indFirstNan:end));
            assert(numNonNans == 0);
            cU = cU(:,1:indFirstNan-1);
            cY = cY(:,1:indFirstNan-1);
        end
        assert(not(any(isnan(cU(:)))));
        
        U{ii} = cU;
        Y{ii} = cY;
        T{ii} = cT;        
    end
end
