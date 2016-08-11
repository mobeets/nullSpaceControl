function [hypInds, hypClrs] = getHypIndsAndClrs(nms, allNms, allHypClrs)
    hypInds = cellfun(@(nm) find(strcmp(allNms, nm)), nms);
    hypClrs = allHypClrs(hypInds,:);
end
