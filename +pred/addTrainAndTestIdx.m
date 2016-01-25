function Blks = addTrainAndTestIdx(Blks0, trainPct)
    if nargin < 2
        trainPct = 0.8;
    end
    Blks = struct([]);
    for ii = 1:numel(Blks0)
        Blk = Blks0(ii);
        N = size(Blk.latents,1);
        cvobj = cvpartition(N, 'HoldOut', 1-trainPct);
        Blk.idxTrain = cvobj.training(1);
        Blk.idxTest = cvobj.test(1);
        Blks = [Blks Blk];
    end
end
