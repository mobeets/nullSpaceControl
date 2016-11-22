function ps = setBlockStartTrials(dtstr)

    [ps.START_SHUFFLE, ps.END_SHUFFLE] = getShuffleStarts(dtstr, ...
        io.shuffleStarts());
    ps.START_WASHOUT = nan;
%     ps.IDEAL_SPEED = 175;

end

function [trial_start, trial_end] = getShuffleStarts(dtstr, SHUFFLE_START)
    ix = SHUFFLE_START(:,1) == str2double(dtstr);
    if sum(ix) == 0
        error(['No entry in SHUFFLE_START for ' dtstr]);
    elseif sum(ix) > 1
        error(['Multiple entries in SHUFFLE_START for ' dtstr]);
    end
    trial_start = SHUFFLE_START(ix,2);
    if size(SHUFFLE_START,2) > 2
        trial_end = SHUFFLE_START(ix,3);
    else
        trial_end = nan;
    end
end
