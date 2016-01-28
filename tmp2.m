

dts = {'20120525', '20120601', '20131125', '20131205'};
fldr = ['plots/kinErr']; %plot.getFldr(D, true);
for dtstr = dts;
    if iscell(dtstr)
        dtstr = dtstr{1};
    end
    clear D;
    close all;

    D = io.loadDataByDate(dtstr);
    D.params = io.loadParams(D);
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);

    ii = 1;
    D.hyps(ii).name = 'observed';
    D.hyps(ii).latents = D.blocks(2).latents;

    ii = 2;
    D.hyps(ii).name = 'habitual';
    D.hyps(ii).latents = pred.habContFit(D);

    tmp(D, D.hyps(2), fldr, {'M1inNulM1'});

end

