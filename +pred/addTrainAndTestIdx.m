function Blks = addTrainAndTestIdx(Blks0, trainPct)
    if nargin < 2
        trainPct = 0.5;
    end
    Blks = struct([]);
    for ii = 1:numel(Blks0)
        Blk = Blks0(ii);
        N = size(Blk.latents,1);
%         if N <= 1
%             Blk.idxTrain = [];
%             Blk.idxTest = [];
%             Blks = [Blks Blk];
%             continue;
%         end
        cvobj = cvpartition(N, 'HoldOut', 1-trainPct);
        Blk.idxTrain = cvobj.training(1);
        Blk.idxTest = cvobj.test(1);
        
        % cv on trial index
        N = numel(unique([Blk.trial_index]));
        cvobj = cvpartition(N, 'HoldOut', 1-trainPct);
        tinds = unique([Blk.trial_index]);
        tinds = tinds(cvobj.training(1));
        Blk.idxTrain = ismember(Blk.trial_index, tinds);
        Blk.idxTest = ~Blk.idxTrain;
        
        % save one kinematic condition to test on
%         trg = 0;
%         Blk.idxTest = Blk.thetas >= trg - 22.5 & Blk.thetas <= trg + 22.5;
%         Blk.idxTrain = ~Blk.idxTest;
        
        Blks = [Blks Blk];
    end
end
