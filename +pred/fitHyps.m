function D = fitHyps(D, nms)
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    if ismember('kinematics mean', nms)
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
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
        D.hyps = pred.addPrediction(D, 'volitional-w-2FAs', pred.volContFit(D, true, 2));
    end
    if ismember('volitional-w-2FAs (s=5)', nms)
        D.hyps = pred.addPrediction(D, 'volitional-w-2FAs (s=5)', pred.volContFit(D, true, 2, 5));
    end
end
