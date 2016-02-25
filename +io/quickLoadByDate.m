function D = quickLoadByDate(dtstr, params)
    if nargin < 2
        params = struct();
    end
    if isa(dtstr, 'double')
        dts = io.getDates();
        dtstr = dts{dtstr};
    end
    D = io.loadDataByDate(dtstr);
    D.params = io.setFilterDefaults(D.params);
    D.params = io.updateParams(D.params, params);
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
%     D = tools.rotateLatentsUpdateDecoders(D, false);
end
