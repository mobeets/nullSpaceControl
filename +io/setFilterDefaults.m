function ps = setFilterDefaults(datestr)
    ps = io.setBlockStartTrials(datestr);
    ps.MIN_DISTANCE = 50;
    ps.MAX_DISTANCE = 125;
    ps.MAX_ANGULAR_ERROR = 360;
    ps.MIN_ANGULAR_ERROR = 0;
    ps.REMOVE_INCORRECTS = true;
    ps.END_SHUFFLE = nan;
    ps.REMOVE_SPEED_TAILS = false;
end
