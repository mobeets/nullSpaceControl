function [Ys, Zs] = patrickAllVals(dts)
    xnm = 'trial_index';
    ynm = 'isCorrect';
    znm = 'trial_length';
    ps = struct('REMOVE_INCORRECTS', false, 'START_SHUFFLE', nan);
    opts = struct('binSz', 50, 'minPtsPerBin', 10, ...
        'doMeanPerTrial', true, 'doSlidingBins', false);
    
    Ys = cell(numel(dts),3);
    Zs = Ys;
    for ii = 1:numel(dts)
        D = io.quickLoadByDate(dts{ii}, ps);
        for jj = 1:numel(D.blocks)
            B = D.blocks(jj);
            [~, Ys{ii,jj}] = behav.smoothAndBinVals(B.(xnm), B.(ynm), opts);
            [~, Zs{ii,jj}] = behav.smoothAndBinVals(B.(xnm), B.(znm), opts);
        end
    end
    
end
