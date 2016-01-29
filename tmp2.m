

dts = {'20120525', '20120601', '20131125', '20131205'};
fldr = '';% 'plots/kinTrialvars';% ['plots/kinNorms']; %plot.getFldr(D, true);
for dtstr = dts;
    if iscell(dtstr)
        dtstr = dtstr{1};
    end
    clear D;
%     close all;

    D = io.loadDataByDate(dtstr);
    D.params.MAX_ANGULAR_ERROR = 360;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    
    ii = 1;
    D.hyps(ii).name = 'habitual';
    D.hyps(ii).latents = pred.habContFit(D);

%     plot.observedNormsByKinematics(D, fldr);
    plot.trialMetricsByKinematics(D.blocks(2), fldr, ...
        [D.datestr ' - unfiltered']);

%     ths = D.blocks(2).thetas + 180;
%     Y1 = D.blocks(2).latents;
%     Y2 = D.hyps(1).latents;
%     [ys, xs] = plot.valsByKinematics(D, ths, Y1, Y2, 8, true, 2);
%     figure;
%     plot.byKinematics(xs, ys, [D.datestr ' - ' D.hyps(1).name], [0.8 0.2 0.2]);

end
