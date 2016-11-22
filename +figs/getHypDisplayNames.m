function nms = getHypDisplayNames(nms, nmsInternal, nmsShown)
    [~,inds] = ismember(nms, nmsInternal);
    nms(inds>0) = nmsShown(inds(inds>0));
end
