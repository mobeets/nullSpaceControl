function ps = setParams(D)

    if strcmp(D.datestr,'20120525')
        START_SHUFFLE = 700;
        START_WASHOUT = 1600;
    elseif strcmp(D.datestr, '20120601')
        START_SHUFFLE = 450;
        START_WASHOUT = 1330;
    elseif strcmp(D.datestr, '20131125')
        START_SHUFFLE = 450;
        START_WASHOUT = 800;
    elseif strcmp(D.datestr, '20131205')
        START_SHUFFLE = 400;
        START_WASHOUT = 800;
    else
        warning('New date: START_SHUFFLE and START_WASHOUT are ''nan''.');
        START_SHUFFLE = nan;
        START_WASHOUT = nan;
    end

    ps.START_SHUFFLE = START_SHUFFLE;
    ps.START_WASHOUT = START_WASHOUT;
    ps.IDEAL_SPEED = 175;    

end
