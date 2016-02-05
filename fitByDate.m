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

    if isa(dtstr, 'double')
        dts = {'20120525', '20120601', '20131125', '20131205'};
        dtstr = dts{dtstr};
    end

    D = io.loadDataByDate(dtstr);
    D.params = io.setFilterDefaults(D.params);
    D.params = io.updateParams(D.params, params);
    
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    D = tools.rotateLatentsUpdateDecoders(D, false);

    if doPred
        D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
        D.hyps = pred.addPrediction(D, 'zero', pred.meanFit(D, 'zero'));
        D.hyps = pred.addPrediction(D, 'best mean', pred.meanFit(D, 'best'));
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
        D.hyps = pred.addPrediction(D, 'volitional', pred.volContFit(D, true, 0));
        D.hyps = pred.addPrediction(D, 'volitional + 2PCs', ...
            pred.volContFit(D, true, 2));
        D = pred.nullActivity(D);
        D = score.scoreAll(D);
        
        if doPlot
            figure; plot.errOfMeans(D.hyps(2:end));
        end
    end
end