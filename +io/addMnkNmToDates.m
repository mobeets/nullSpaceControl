function [dts, ixJfy] = addMnkNmToDates(dts)

    ixJfy = cellfun(@(c) numel(strfind(c, '2012')) > 0, dts);
    dts(ixJfy) = cellfun(@(c) ['J' c], dts(ixJfy), 'uni', 0);
    dts(~ixJfy) = cellfun(@(c) ['L' c], dts(~ixJfy), 'uni', 0);

end
