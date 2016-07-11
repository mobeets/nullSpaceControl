function ps = setBlockStartTrials(datestr)

    if strcmp(datestr, '20120303')
        START_SHUFFLE = 446;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120308')
        START_SHUFFLE = 668;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120319')
        START_SHUFFLE = 768;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120327')
        START_SHUFFLE = 453;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120331')
        START_SHUFFLE = 897;
        START_WASHOUT = nan;
    elseif strcmp(datestr,'20120525')
        START_SHUFFLE = 658;
        START_WASHOUT = 1600;
    elseif strcmp(datestr, '20120601')
        START_SHUFFLE = 419;
        START_WASHOUT = 1330;
    elseif strcmp(datestr, '20120709')
        START_SHUFFLE = 709;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20131125')
        START_SHUFFLE = 545;
        START_WASHOUT = 800;
    elseif strcmp(datestr, '20131205')
        START_SHUFFLE = 405;
        START_WASHOUT = 800;
    elseif strcmp(datestr, '20131211')
        START_SHUFFLE = 403;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20131212')
        START_SHUFFLE = 451;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20131218')
        START_SHUFFLE = 486;
        START_WASHOUT = nan;
    else
        warning('New date: START_SHUFFLE and START_WASHOUT are ''nan''.');
        START_SHUFFLE = nan;
        START_WASHOUT = nan;
    end

    ps.START_SHUFFLE = START_SHUFFLE;
    ps.START_WASHOUT = START_WASHOUT;
%     ps.IDEAL_SPEED = 175;

end
