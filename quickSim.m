function quickSim(D)
%     dtstr = '20120601';
%     params = struct('MAX_ANGULAR_ERROR', 360);
%     hyps = {'kinematics mean', 'habitual', 'cloud-hab', 'volitional-w-2FAs (s=5)'};
%     D = fitByDate(dtstr, params, hyps, [], struct('doRotate', false));

    Ys = {D.blocks(2).latents};
    nms = {'true'};
    opts = struct('doSample', false);
%     cloudopts = struct('doSample', false, 'kNN', 100, 'minDist', nan);
    cloudopts = struct('doSample', false, 'minDist', 0.5, 'thetaTol', 20);
    [Ys, nms] = addSims(Ys, nms, D, @(D) pred.habContFit(D, opts), 'sim hab');
    [Ys, nms] = addSims(Ys, nms, D, @(D) pred.sameCloudFit(D, cloudopts), 'sim cloud');
    
    for ii = 1:numel(nms)
        nm = nms{ii}
        lts = Ys{ii};
        D.blocks(2).latents = lts;
        D.hyps = pred.addPrediction(D, 'observed', lts);
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
        D = pred.nullActivity(D);
        D = score.scoreAll(D);
        plot.plotScores(D, [D.datestr ' ' nm]);
    end

end

function [Ys, nms] = addSims(Ys, nms, D, simFcn, nm)
    lts0 = simFcn(D);
    decoder = D.simpleData.nullDecoder;
    sps1 = tools.latentsToSpikes(lts0, decoder);
    lts1 = tools.convertRawSpikesToRawLatents(decoder, sps1');
    sps2 = tools.latentsToSpikes(lts0, decoder, true);
    lts2 = tools.convertRawSpikesToRawLatents(decoder, sps2');
    Ys = [Ys lts0 lts1 lts2];
    nms = [nms [nm ' - raw'] [nm ' - noNse'] [nm ' - Nse']];
end
