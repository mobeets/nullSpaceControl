function D = addAndScoreHypothesis(D, Z, nm, hypopts)
    if nargin < 4
        hypopts = struct();
    end

    E = pred.fitHyps(rmfield(D, 'hyps'), {});
    E.hyps = pred.addPrediction(E, nm, Z);
    E = score.scoreAll(E, hypopts);
    D.hyps = [D.hyps E.hyps(end)];

end
