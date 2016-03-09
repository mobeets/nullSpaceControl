function D = quickLoadByDate(dtstr, params, doRotate, doStretch)
    if nargin < 2
        params = struct();
    end
    if nargin < 3
        doRotate = true;
    end
    if nargin < 4
        doStretch = true;
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
    
    if doRotate
        D = tools.rotateLatentsUpdateDecoders(D, doStretch);
    end
end
