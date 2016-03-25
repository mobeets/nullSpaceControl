function D = fitHyps(D, nms, opts)
% in future, will past list of structs, and will call each one's pred fcn
% where each predFcn is called like predFcn(D, opts)
% 
    if nargin < 3
        opts = struct();
    end
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    if ismember('kinematics mean', nms)
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, opts));
    end
    if ismember('habitual', nms)
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D, opts));
    end
    if ismember('cloud-hab', nms)
        D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, opts));
    end
    if ismember('baseline', nms)
        D.hyps = pred.addPrediction(D, 'baseline', pred.baseFireFit(D, opts));
    end
    if ismember('minimum', nms)
        D.hyps = pred.addPrediction(D, 'minimum', pred.minFireFit(D, opts));
    end
    if ismember('unconstrained', nms)
        D.hyps = pred.addPrediction(D, 'unconstrained', pred.uncContFit(D, opts));
    end
    if ismember('volitional-w-2FAs', nms) || ismember('volitional', nms)
        custopts = struct('addPrecursor', true, 'useL', 2);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'volitional', pred.volContFit(D, custopts));
    end
    if ismember('volitional-w-2FAs (s=5)', nms)
        custopts = struct('addPrecursor', true, 'useL', 2, 'scaleVol', 5);
        custopts = io.updateParams(opts, custopts, true);
        D.hyps = pred.addPrediction(D, 'volitional-w-2FAs (s=5)', pred.volContFit(D, custopts));
    end
end
