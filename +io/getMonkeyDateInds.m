function ix = getMonkeyDateInds(dts, mnkNm)
    ix = cellfun(@(d) ~isempty(strfind(d, mnkNm(1))), ...
        io.addMnkNmToDates(dts));
end
