function [Act, Preds] = nullActivity(T1, T2, B, Act, Preds)

    [zMu, zCov] = nullActivityByTrgAng(T1, Act.Z, B);
    Act.T1.zMu = zMu;
    Act.T1.zCov = zCov;
    [zMu, zCov] = nullActivityByTrgAng(T2, Act.Z, B);
    Act.T2.zMu = zMu;
    Act.T2.zCov = zCov;

    hyps = fieldnames(Preds);
    nhyps = numel(hyps);

    for ii = 1:nhyps
        hypnm = hyps{ii};
        Pred = Preds.(hypnm);
        
        [zMu0, zCov0] = nullActivityByTrgAng(T2, Pred.Z, B);
        Preds.(hypnm).T2.zMu = zMu0;
        Preds.(hypnm).T2.zCov = zCov0;
    end

end
