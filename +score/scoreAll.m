function [errOfMeans, covRatio] = scoreAll(Act, Preds)

    zMu = Act.T2.zMu;
    zCov = Act.T2.zCov;
    
    hyps = fieldnames(Preds);
    nhyps = numel(hyps);
    errOfMeans = nan(nhyps,1);
    covRatio = nan(nhyps,1);

    for ii = 1:nhyps
        hypnm = hyps{ii};
        zMu0 = Preds.(hypnm).T2.zMu;
        zCov0 = Preds.(hypnm).T2.zCov;
        errOfMeans(ii) = score.errOfMeans(zMu, zMu0);
        covRatio(ii) = score.covRatio(zCov, zCov0);
    end

end
