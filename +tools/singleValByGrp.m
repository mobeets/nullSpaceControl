function [vs, grps] = singleValByGrp(vals, gs, fcn)

    grps = sort(unique(gs));    
    vs = arrayfun(@(grp) fcn(vals(gs == grp,:)), grps);

end
