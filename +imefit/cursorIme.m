function [pos_ime, ths_ime] = cursorIme(B, ime)
% cursor movement using ime decoder

    [U, Y, Xtarget, ~] = imefit.prep(B);
    [E_P, ~] = velime_extract_prior_whiskers(U, Y, Xtarget, ime);
    assert(isequal(cell2mat(Y)', B.pos));
    % n.b. E_P{t} always has at least T_START cols, but Y{t} may have fewer
    pos_ime = arrayfun(@(t) E_P{t}(1:2,1:size(Y{t},2)), 1:numel(E_P), ...
        'uni', 0);
    pos_ime = cell2mat(pos_ime)';
    
    vec2trg = B.target - pos_ime;
    ths_ime = arrayfun(@(t) tools.computeAngle(vec2trg(t,:), [1; 0]), ...
        1:size(vec2trg,1));
    ths_ime = mod(ths_ime, 360);

end
