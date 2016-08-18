function [hypInds, hypClrs] = getHypIndsAndClrs(nms, allNms, allHypClrs)
    hypInds = cellfun(@(nm) find(strcmp(allNms, nm)), nms);
    if nargin > 2
        hypClrs = allHypClrs(hypInds,:);
    end
end
