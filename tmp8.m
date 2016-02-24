
dts = {'20120525', '20120601', '20131125', '20131205'};
for ii = 1:numel(dts)
    dtstr = dts{ii};
    D = io.loadDataByDate(dtstr);
    D.params = io.setFilterDefaults(D.params);
    D.params.MAX_ANGULAR_ERROR = 360;
    D.params.MIN_DISTANCE = 0;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    D = tools.rotateLatentsUpdateDecoders(D, true);

%     D = rmfield(D, 'hyps');
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
    D.hyps = pred.addPrediction(D, 'vol w/ 2Fs', pred.volContFit(D, true, 2));

    D = pred.nullActivity(D);
    D = score.scoreAll(D);
%     close all;
    figure; set(gcf, 'color', 'w');
    subplot(1,3,1); hold on; plot.errOfMeans(D.hyps(2:end), D.datestr);
    subplot(1,3,2); hold on; plot.covError(D.hyps(2:end), D.datestr, 'covErrorOrient');
    subplot(1,3,3); hold on; plot.covError(D.hyps(2:end), D.datestr, 'covErrorShape');
    fig = gcf; saveas(fig, ['plots/cloud_scores/2' dtstr], 'png');
    
    figure; set(gcf, 'color', 'w');
    subplot(1,3,1); hold on; plot.errOfMeans(D.hyps(2:end-1), D.datestr);
    subplot(1,3,2); hold on; plot.covError(D.hyps(2:end-1), D.datestr, 'covErrorOrient');
    subplot(1,3,3); hold on; plot.covError(D.hyps(2:end-1), D.datestr, 'covErrorShape');
    fig = gcf; saveas(fig, ['plots/cloud_scores/2' dtstr '-novol'], 'png');
end
