function D = addAndScoreHypothesis(D, Z, nm)

    E = pred.fitHyps(rmfield(D, 'hyps'), {});
    E.hyps = pred.addPrediction(E, nm, Z);
    E = pred.nullActivity(E);
    E = score.scoreAll(E, true);
    D.hyps = [D.hyps E.hyps(end)];

end
