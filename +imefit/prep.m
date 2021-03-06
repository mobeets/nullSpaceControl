function [U, Y, T, trs] = prep(B, doLatents, doWarn, keepIncorrects)
% U = [1 ntrials] cell, U(1) = [ncells ntimes] double
% Y = [1 ntrials] cell, Y(1) = [2 ntimes] double
% T = [1 ntrials] cell, T(1) = [2 1] double
    if nargin < 2
        doLatents = false;
    end
    if nargin < 3
        doWarn = true;
    end
    if nargin < 4
        keepIncorrects = false;
    end
    
    B.latents(2:end,:) = B.latents(1:end-1,:);
    B.spikes(2:end,:) = B.spikes(1:end-1,:);
    ib = logical(B.isCorrect);
    if keepIncorrects
        ib = true(size(ib));
    end

    ts = B.trial_index;
    trs = sort(unique(ts(ib)));
    ntrs = numel(trs);
    U = cell(1, ntrs);
    Y = cell(size(U));
    T = cell(size(U));
    didWarn = ~doWarn; % if doWarn is false, never warn
    for ii = 1:ntrs
        it = (ts == trs(ii)) & ib;
        
        % ensure all times are accounted for; remove first 6 time-points
        tms = B.time(it);
        ntms = max(tms); 
        alltms = sort(tms);
        if ~isequal(alltms', 1:ntms) && ~didWarn
            warning(['Not all times are present. ' ...
                'If fitting IME, make sure you turn off filtering.']);
            didWarn = true;
        end
        it = B.time >= 6 & it;

        % target position
        cT = B.target(find(it, 1, 'first'),:)'; % 1x2

        % cursor position
        cY = B.pos(it,:)';

        % spikes (or latents)
        cU = B.spikes(it,:)';
        if doLatents
            cU = B.latents(it,:)';
        end

        % remove columns with nans
        assert(not(any(isnan(cY(:)))));
        assert(not(any(isnan(cT(:)))));
        if any(isnan(cU(:)))
            ixNan = any(isnan(cU));
            indFirstNan = find(ixNan, 1, 'first');
            numNonNans = sum(~ixNan(indFirstNan:end));
%             assert(numNonNans == 0);
            cU = cU(:,1:indFirstNan-1);
            cY = cY(:,1:indFirstNan-1);
        end
        assert(not(any(isnan(cU(:)))));
        
        U{ii} = cU;
        Y{ii} = cY;
        T{ii} = cT;        
    end
end
