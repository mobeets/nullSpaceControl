function [dts, inds] = addMnkNmToDates(dts)

    mnks = io.getMonkeys();
    inds = nan(numel(dts),1);
    for ii = 1:numel(mnks)
        dtsCur = io.getDates(false, true, mnks(ii));
        prefix = mnks{ii}(1);
        ixCur = ismember(dts, dtsCur);
        dts(ixCur) = cellfun(@(dt) [prefix dt], dts(ixCur), 'uni', 0);
        inds(ixCur) = ii;
    end

end
