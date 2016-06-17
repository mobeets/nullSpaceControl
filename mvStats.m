function [ths_ime, angErr_ime, thsact_ime] = mvStats(B, pos_ime)
    vec2trg = B.target - pos_ime;
    movVec = diff(pos_ime); % or do we compare true pos to next pos_ime?
    
    ths_ime = arrayfun(@(t) tools.computeAngle(vec2trg(t,:), [1; 0]), ...
        1:size(vec2trg,1))';
    ths_ime = mod(ths_ime, 360);
    
    angErr_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), ...
        vec2trg(t,:)), 1:size(vec2trg,1)-1);
    angErr_ime = [angErr_ime nan]'; % for last time step
    
    thsact_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), [1; 0]), ...
        1:size(movVec,1))';
    thsact_ime = [thsact_ime; nan]; % for last time step
    thsact_ime = mod(thsact_ime, 360);

    ix = diff(B.trial_index) ~= 0 | diff(B.time) ~= 1;
    thsact_ime(ix) = nan;
    angErr_ime(ix) = nan;
end
