function [hypinds, hypClrs] = getHypIndsAndClrs(nms, allNms, allHypClrs)
    hypinds = cellfun(@(nm) find(strcmp(allNms, nm)), nms);
    if nargin > 2
        hypClrs = allHypClrs(hypinds,:);
    end
end
