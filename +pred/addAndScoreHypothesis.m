function D = addAndScoreHypothesis(D, Z, nm, hypopts)
    if nargin < 4
        hypopts = struct();
    end
    if ~isa(Z, 'cell')
        Zs{1} = Z;
        nms{1} = nm;
    else
        Zs = Z; nms = nm;
    end
    E = pred.fitHyps(rmfield(D, 'hyps'), {});
    for ii = 1:numel(Zs)
        E.hyps = pred.addPrediction(E, nms{ii}, Zs{ii});
    end
    D.hyps = rmfield(D.hyps, {'grps', 'marginalHist', 'nullActivity', ...
        'jointKde'});
    D.hyps = [D.hyps E.hyps(2:end)];
    D = score.scoreAll(rmfield(D, 'scores'), hypopts);

end
