function ps = setBlockStartTrials(datestr)

    if strcmp(datestr,'20120525')
        START_SHUFFLE = 657; % 700
        START_WASHOUT = 1600;
    elseif strcmp(datestr, '20120601')
        START_SHUFFLE = 419; % 450
        START_WASHOUT = 1330;
    elseif strcmp(datestr, '20131125')
        START_SHUFFLE = 450; % 544
        START_WASHOUT = 800;
    elseif strcmp(datestr, '20131205')
        START_SHUFFLE = 400; % 404
        START_WASHOUT = 800;
    elseif strcmp(datestr, '20120709')
        START_SHUFFLE = 708;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120331')
        START_SHUFFLE = 897;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120327')
        START_SHUFFLE = 453;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20120308')
        START_SHUFFLE = 668;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20131211')
        START_SHUFFLE = 668;
        START_WASHOUT = nan;
    elseif strcmp(datestr, '20131212')
        START_SHUFFLE = 400;
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
