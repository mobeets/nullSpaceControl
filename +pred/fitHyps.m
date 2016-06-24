function D = fitHyps(D, nms, opts)
% in future, will past list of structs, and will call each one's pred fcn
% where each predFcn is called like predFcn(D, opts)
% 
    if nargin < 3
        opts = struct();
    end
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    if ismember('true', nms)
        D.hyps = pred.addPrediction(D, 'true', pred.cvMeanFit(D, opts));
    end
    if ismember('best-sample', nms)
        % best sampling method
        D.hyps = pred.addPrediction(D, 'best-sample', ...
            pred.closestNulValFit_cheat(D, opts));
    end
    if ismember('best-habitual-inv', nms)
        % best inv-habitual method
        D.hyps = pred.addPrediction(D, 'best-habitual-inv', ...
            pred.closestNulValNotInGrpFit_cheat(D, opts));
    end
    if ismember('best-habitual', nms)
        % best habitual method
        D.hyps = pred.addPrediction(D, 'best-habitual', ...
            pred.closestNulValInGrpFit_cheat(D, opts));
    end
    if ismember('best-cloud-20', nms)
        % best habitual method
        D.hyps = pred.addPrediction(D, 'best-cloud-20', ...
            pred.closestNulValWithCloseRowValFit_cheat(D, opts));
    end
    
    if ismember('cloud-1s', nms)
        % this is the same as "cloud-1", but more simply implemented
        D.hyps = pred.addPrediction(D, 'cloud-1s', ...
            pred.closestRowValFit(D, opts));
    end
    if ismember('pruning-1s', nms)
        % this is the same as "pruning-1", but more simply implemented
        D.hyps = pred.addPrediction(D, 'pruning-1s', ...
            pred.closestRowValInGrpFit(D, opts));
    end
    if ismember('pruning-reverse', nms)
        D.hyps = pred.addPrediction(D, 'pruning-reverse', ...
            pred.closestThetaWithCloseRowValFit(D, opts));
    end

    if ismember('habitual', nms)        
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D, opts));
    end
    if ismember('hab-kde', nms)        
        D.hyps = pred.addPrediction(D, 'hab-kde', pred.habKdeFit(D, opts));
    end
    if ismember('pruning', nms) || ismember('cloud-hab', nms)
        D.hyps = pred.addPrediction(D, 'pruning', pred.sameCloudFit(D, opts));
    end
    if ismember('pruning-1', nms)
        custopts = struct('minDist', nan, 'kNN', 1);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'pruning-1', pred.sameCloudFit(D, custopts));
    end    
    if ismember('cloud', nms) || ismember('cloud-1', nms)
        custopts = struct('thetaTol', nan, 'minDist', nan, 'kNN', 1);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'cloud', pred.sameCloudFit(D, custopts));
    end
    if ismember('cloud-og', nms)
        custopts = struct('thetaTol', nan, 'minDist', nan, 'kNN', 200);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'cloud-og', pred.sameCloudFit(D, custopts));
    end
    if ismember('unconstrained', nms)
        D.hyps = pred.addPrediction(D, 'unconstrained', pred.uncContFit(D, opts));
    end
    if ismember('baseline', nms)
        D.hyps = pred.addPrediction(D, 'baseline', pred.minEnergyFit(D, opts));
    end
    if ismember('minimum', nms)
        custopts = struct('minType', 'minimum');
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'minimum', pred.minEnergyFit(D, custopts));
    end    
    if ismember('volitional-w-2FAs', nms) || ismember('volitional', nms)
        custopts = struct('addPrecursor', true, 'useL', 2);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'volitional', pred.volContFit(D, custopts));
    end
    if ismember('volitional-w-2FAs (s=5)', nms) || ismember('volitional-s5', nms)
        custopts = struct('addPrecursor', true, 'useL', 2, 'scaleVol', 5);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'volitional-s5', pred.volContFit(D, custopts));
    end
    if ismember('conditional', nms)
        D.hyps = pred.addPrediction(D, 'conditional', pred.condFit(D, opts));
    end
    if ismember('conditional-thetas', nms)
        custopts = struct('useThetas', true);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'conditional-thetas', pred.condFit(D, custopts));
    end
    if ismember('condnrm', nms)
        D.hyps = pred.addPrediction(D, 'condnrm', pred.condGaussFit(D, opts));
    end
    if ismember('condnrmkin', nms)
        custopts = struct('byThetaGrps', true);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'condnrmkin', pred.condGaussFit(D, custopts));
    end
    if ismember('mean shift prune', nms)
        rotThetas = pred.rotThetasFromMeanShift(D, struct('thetaTol', inf));
        custopts = struct('rotThetas', -rotThetas);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'prune + mean shift', pred.sameCloudFit(D, custopts));
    end
    if ismember('mean shift og', nms)
        rotThetas = -pred.findReaimingAnglesWithIntuitive(D);
        custopts = struct('rotThetas', -rotThetas);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'prune + mean shift og', pred.sameCloudFit(D, custopts));
    end
    if ismember('mean shift', nms)
        D.hyps = pred.addPrediction(D, 'mean shift', pred.meanShiftFit(D, opts));
    end
    if ismember('zero', nms)
        D.hyps = pred.addPrediction(D, 'zero', pred.dummyFit(D, opts));
    end
    if ismember('uniform', nms)
        D.hyps = pred.addPrediction(D, 'uniform', pred.uniFit(D, opts));
    end
end
