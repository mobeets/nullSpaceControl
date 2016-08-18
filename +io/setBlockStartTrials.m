function ps = setBlockStartTrials(dtstr)

    ps.START_SHUFFLE = getShuffleStarts(dtstr, io.shuffleStarts);
    ps.START_WASHOUT = nan;
%     ps.IDEAL_SPEED = 175;

end

function trial_index = getShuffleStarts(dtstr, SHUFFLE_START)
    ix = SHUFFLE_START(:,1) == str2double(dtstr);
    if sum(ix) == 0
        error(['No entry in SHUFFLE_START for ' dtstr]);
    elseif sum(ix) > 1
        error(['Multiple entries in SHUFFLE_START for ' dtstr]);
    end
    trial_index = SHUFFLE_START(ix,2);
end
