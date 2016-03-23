function D = fitHyps(D, nms)
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    if ismember('kinematics mean', nms)
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D));
    end
    if ismember('habitual', nms)
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    end
    if ismember('cloud-hab', nms)
        D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D));
    end
    if ismember('baseline', nms)
        D.hyps = pred.addPrediction(D, 'baseline', pred.baseFireFit(D));
    end
    if ismember('minimum', nms)
        D.hyps = pred.addPrediction(D, 'minimum', pred.minFireFit(D));
    end
    if ismember('unconstrained', nms)
        D.hyps = pred.addPrediction(D, 'unconstrained', pred.uncContFit(D));
    end
    if ismember('volitional-w-2FAs', nms)
        opts = struct('addPrecursor', true, 'useL', 2);
        D.hyps = pred.addPrediction(D, 'volitional-w-2FAs', pred.volContFit(D, opts));
    end
    if ismember('volitional-w-2FAs (s=5)', nms)
        opts = struct('addPrecursor', true, 'useL', 2, 'scaleVol', 5);
        D.hyps = pred.addPrediction(D, 'volitional-w-2FAs (s=5)', pred.volContFit(D, opts));
    end
end
