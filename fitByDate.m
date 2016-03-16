function D = fitByDate(dtstr, plotArgs, params, nms)
% 20120525 20120601 20131125 20131205
    if nargin < 2
        plotArgs = [false false false]; % doSave, isMaster, doSolos
    end
    if nargin < 3
        params = struct();
    end
    if nargin < 4
        nms = {'kinematics mean', 'habitual', 'cloud-hab'};
    end
    D = io.quickLoadByDate(dtstr, params);
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    D = fitHyps(D, nms);
    D = pred.nullActivity(D);
    D = score.scoreAll(D);

    if ~isempty(plotArgs)
        plot.plotAll(D, D.hyps(2:end), plotArgs(1), plotArgs(2), plotArgs(3));
    end
end

function D = fitHyps(D, nms)
    if ismember('kinematics mean', nms)
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
    end
    if ismember('habitual', nms)
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    end
    if ismember('cloud-hab', nms)
        D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
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
