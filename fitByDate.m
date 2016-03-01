function D = fitByDate(dtstr, plotArgs, params)
% 20120525 20120601 20131125 20131205
    if nargin < 2
        plotArgs = [false false false]; % doSave, isMaster, doSolos
    end
    if nargin < 3
        params = struct();
    end
    D = io.quickLoadByDate(dtstr, params);

    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
    D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
    D.hyps = pred.addPrediction(D, 'volitional + 2PCs', ...
        pred.volContFit(D, true, 2));
    D = pred.nullActivity(D);
    D = score.scoreAll(D);

    if ~isempty(plotArgs)
        plot.plotAll(D, D.hyps(2:end), plotArgs(1), plotArgs(2), plotArgs(3));
    end
end
