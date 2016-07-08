function D = splitIntuitiveBlock(D, bind, trainPct, ignoreTrain)
    if nargin < 2
        bind = 1;
    end
    if nargin < 3
        trainPct = 0.5;
    end
    if nargin < 4
        ignoreTrain = false;
    end

    B = D.blocks(bind);
    ts = B.trial_index;
    Ts = unique(ts);
    
%     trSplit = prctile(Ts, trainPct*100);
%     ixTrain = ts <= trSplit;
    
    cvobj = cvpartition(numel(Ts), 'HoldOut', trainPct);
    ixTrTrain = cvobj.training(1);
    ixTrain = ismember(ts, Ts(ixTrTrain));
    
    if ~ignoreTrain
        D.blocks(1) = io.filterTrialsByIdx(B, ixTrain);
    end
    D.blocks(2) = io.filterTrialsByIdx(B, ~ixTrain);
    
    if bind == 2
        D = io.makeImeDefault(D);
    end

end
