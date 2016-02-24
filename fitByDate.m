function D = fitByDate(dtstr, doPred, doPlot, params)
% 20120525 20120601 20131125 20131205
    if nargin < 2
        doPred = false;
    end
    if nargin < 3
        doPlot = false;
    end
    if nargin < 4
        params = struct();
    end
    D = io.quickLoadByDate(dtstr, params);

    if doPred
        D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
        D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
        D.hyps = pred.addPrediction(D, 'volitional + 2PCs', ...
            pred.volContFit(D, true, 2));
        D = pred.nullActivity(D);
        D = score.scoreAll(D);
        
        if doPlot
            plot.plotAll(D, D.hyps(2:end), true, true, true);
        end
    end
end
