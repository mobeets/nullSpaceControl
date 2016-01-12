function ps = loadParams(d)

if strcmp(d.datestr,'20120525')
    START_SHUFFLE = 700;
    START_WASHOUT = 1600;
elseif strcmp(d.datestr, '20120601')
    START_SHUFFLE = 450;
    START_WASHOUT = 1330;
elseif strcmp(d.datestr, '20131125')
    START_SHUFFLE = 450;
    START_WASHOUT = 800;
elseif strcmp(d.datestr, '20131205')
    START_SHUFFLE = 400;
    START_WASHOUT = 800;
else
    error('Date not supported yet')
end

ps.START_SHUFFLE = START_SHUFFLE;
ps.START_WASHOUT = START_WASHOUT;
ps.MIN_DISTANCE = 50;
ps.MAX_DISTANCE = 125;
ps.MAX_ANGULAR_ERROR = 20;
ps.IDEAL_SPEED = 175;

end
