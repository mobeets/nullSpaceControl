function ps = setFilterDefaults(datestr)
    ps = io.setParams(datestr);
    ps.MIN_DISTANCE = 50;
    ps.MAX_DISTANCE = 125;
    ps.MAX_ANGULAR_ERROR = 20;
    ps.MIN_ANGULAR_ERROR = 0;
    ps.REMOVE_INCORRECTS = true;
    ps.END_SHUFFLE = nan;    
end
