

dts = {'20120525', '20120601', '20131125', '20131205'};
fldr = ['plots/kinNorms']; %plot.getFldr(D, true);
for dtstr = dts;
    if iscell(dtstr)
        dtstr = dtstr{1};
    end
    clear D;
    close all;

    D = io.loadDataByDate(dtstr);    
    D.params = io.setFilterDefaults(D.params);
%     D.params.MAX_ANGULAR_ERROR = 360;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);

    plot.observedNormsByKinematics(D, fldr);

end
