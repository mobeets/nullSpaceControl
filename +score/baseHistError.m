function errs = baseHistError(Y, Xs, gs, histopts, trainPct, nboots)
    if nargin < 4
        histopts = struct();
    end
    if nargin < 5
        trainPct = 0.5;
    end
    if nargin < 6
        nboots = 10;
    end
    
    errs = cell(nboots,1);
    for ii = 1:nboots
        % split training/testing
        cvobj = cvpartition(size(Y,1), 'HoldOut', 1-trainPct);
        idxTrain = cvobj.training(1);
        idxTest = cvobj.test(1);

        % score
        Z = tools.marginalDist(Y(idxTrain,:), gs(idxTrain), histopts, Xs);
        Zh = tools.marginalDist(Y(idxTest,:), gs(idxTest), histopts, Xs);
        errs{ii} = score.histError(Z, Zh);
    end
    errs = mean(cat(3, errs{:}), 3);

end
