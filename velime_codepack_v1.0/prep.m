function [U, Y, T] = prep(dtstr)
% U = [1 ntrials] cell, U(1) = [ncells ntimes] double
% Y = [1 ntrials] cell, Y(1) = [2 ntimes] double
% T = [1 ntrials] cell, T(1) = [2 1] double

    params = struct('START_SHUFFLE', nan);
    D = fitByDate(dtstr, params);
    B = D.trials;
    ib = B.block_index == 2;

    ts = B.trial_index;
    trs = sort(unique(ts(ib)));
    ntrs = numel(trs);
    U = cell(1, ntrs);
    Y = cell(size(U));
    T = cell(size(U));
    ncells = size(B.latents,2);
    for ii = 1:ntrs
        it = (ts == trs(ii)) & ib;
        tms = B.time(it);
        ntms = max(tms);

        % warning: need to assert all times are accounted for
        assert(all(sort(tms)' == 1:ntms));

        % target position
        cT = B.target(find(it, 1, 'first'),:)'; % 1x2

        % cursor position
        cY = B.pos(it,:)';

        % spikes
        cU = B.latents(it,:)';

        assert(not(any(isnan(cY(:)))));
        assert(not(any(isnan(cT(:)))));
        if any(isnan(cU(:)))
            ixNan = any(isnan(cU));
            numNonNans = sum(~ixNan(find(ixNan, 1, 'first')+1:end));
            assert(numNonNans == 0);
        end        
        
        U{ii} = cU;
        Y{ii} = cY;
        T{ii} = cT;        
    end
end
