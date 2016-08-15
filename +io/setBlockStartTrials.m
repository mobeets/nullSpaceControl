function ps = setBlockStartTrials(dtstr)

    ps.START_SHUFFLE = io.shuffleStarts(dtstr);
    ps.START_WASHOUT = nan;
%     ps.IDEAL_SPEED = 175;

end
